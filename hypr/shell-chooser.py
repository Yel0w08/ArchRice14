#!/usr/bin/env python3
"""Hyprland shell chooser — riced full-screen overlay.

Shown on Hyprland start when no shell was pre-selected by a session script.
Full-screen, frameless, themed to match the desktop palette. Pick a shell by
clicking its card (or pressing 1 / 2 / Enter). Esc or the timeout skips.

Logos: Caelestia's from /etc/xdg/quickshell/caelestia/assets/logo.svg,
       Noctalia's from /usr/share/noctalia/assets/noctalia.svg.
"""

import os
import subprocess
import sys

from PySide6.QtCore import Qt, QTimer, QSize, QPropertyAnimation, QEasingCurve
from PySide6.QtGui import QColor, QFont, QPalette, QPixmap
from PySide6.QtSvgWidgets import QSvgWidget
from PySide6.QtWidgets import (
    QApplication,
    QFrame,
    QGraphicsDropShadowEffect,
    QHBoxLayout,
    QLabel,
    QVBoxLayout,
    QWidget,
)

# Palette from ~/.config/hypr/scheme/current.lua
BG = "#08080a"
SURFACE = "#0e0e12"
SURFACE_HIGH = "#131317"
SURFACE_HIGHEST = "#1c1b1f"
PRIMARY = "#c2c1ff"
ON_SURFACE = "#e5e1e7"
ON_SURFACE_VARIANT = "#c8c5d1"
OUTLINE = "#47464f"
TERTIARY = "#f5b2e0"
ERROR = "#ffb4ab"

LOGOS = {
    "Caelestia": "/etc/xdg/quickshell/caelestia/assets/logo.svg",
    "Noctalia": "/usr/share/noctalia/assets/noctalia.svg",
}

SHELLS = {
    "Caelestia": {
        "cmd": ["caelestia", "shell", "-d"],
        "log": os.path.expanduser("~/.cache/caelestia.log"),
        "accent": PRIMARY,
    },
    "Noctalia": {
        "cmd": ["noctalia", "-d"],
        "log": os.path.expanduser("~/.cache/noctalia.log"),
        "accent": TERTIARY,
    },
}

TIMEOUT_MS = 20000


def start_shell(name: str) -> None:
    spec = SHELLS[name]
    try:
        with open(spec["log"], "a") as f:
            subprocess.Popen(
                spec["cmd"],
                stdout=f,
                stderr=subprocess.STDOUT,
                start_new_session=True,
            )
    except FileNotFoundError:
        pass


class ShellCard(QFrame):
    """A big clickable card: logo + name, with hover glow."""

    def __init__(self, name: str, spec: dict, parent=None):
        super().__init__(parent)
        self.name = name
        self.spec = spec
        self.accent = spec["accent"]
        self._hovered = False

        self.setFixedSize(260, 320)
        self.setCursor(Qt.CursorShape.PointingHandCursor)
        self.setObjectName("shellCard")

        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 32, 24, 28)
        layout.setSpacing(20)
        layout.setAlignment(Qt.AlignmentFlag.AlignCenter)

        # Logo
        logo_path = LOGOS[name]
        self.logo = QSvgWidget(logo_path)
        self.logo.setFixedSize(120, 120)
        self.logo.setStyleSheet("background: transparent;")
        layout.addWidget(self.logo, 0, Qt.AlignmentFlag.AlignCenter)

        # Name
        self.label = QLabel(name)
        self.label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.label.setStyleSheet(
            f"color: {ON_SURFACE}; font-size: 22px; font-weight: 700; "
            f"background: transparent; letter-spacing: 1px;"
        )
        layout.addWidget(self.label)

        # Accent underline
        self.underline = QFrame()
        self.underline.setFixedHeight(3)
        self.underline.setFixedWidth(60)
        self.underline.setStyleSheet(f"background: {self.accent}; border-radius: 2px;")
        layout.addWidget(self.underline, 0, Qt.AlignmentFlag.AlignCenter)

        self._apply_style(False)

        # Hover glow
        self._shadow = QGraphicsDropShadowEffect(self)
        self._shadow.setBlurRadius(0)
        self._shadow.setColor(QColor(self.accent))
        self._shadow.setOffset(0, 0)
        self.setGraphicsEffect(self._shadow)

    def _apply_style(self, hovered: bool) -> None:
        if hovered:
            self.setStyleSheet(
                f"""
                QFrame#shellCard {{
                    background: {SURFACE_HIGH};
                    border: 2px solid {self.accent};
                    border-radius: 20px;
                }}
                """
            )
        else:
            self.setStyleSheet(
                f"""
                QFrame#shellCard {{
                    background: {SURFACE};
                    border: 2px solid {OUTLINE};
                    border-radius: 20px;
                }}
                """
            )

    def enterEvent(self, event) -> None:
        self._hovered = True
        self._apply_style(True)
        # animate glow in
        anim = QPropertyAnimation(self._shadow, b"blurRadius", self)
        anim.setDuration(180)
        anim.setStartValue(self._shadow.blurRadius())
        anim.setEndValue(40)
        anim.setEasingCurve(QEasingCurve.Type.OutCubic)
        anim.start()
        # keep reference to avoid GC
        self._anim = anim
        super().enterEvent(event)

    def leaveEvent(self, event) -> None:
        self._hovered = False
        self._apply_style(False)
        anim = QPropertyAnimation(self._shadow, b"blurRadius", self)
        anim.setDuration(180)
        anim.setStartValue(self._shadow.blurRadius())
        anim.setEndValue(0)
        anim.setEasingCurve(QEasingCurve.Type.OutCubic)
        anim.start()
        self._anim = anim
        super().leaveEvent(event)

    def mousePressEvent(self, event) -> None:
        if event.button() == Qt.MouseButton.LeftButton:
            self.parent().pick(self.name)
        super().mousePressEvent(event)


class Chooser(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Shell Chooser")
        self.setWindowFlags(
            Qt.WindowType.FramelessWindowHint
            | Qt.WindowType.WindowStaysOnTopHint
            | Qt.WindowType.Tool
        )
        # Full screen
        screen = QApplication.primaryScreen().geometry()
        self.setGeometry(screen)
        self.setStyleSheet(f"background: {BG};")

        root = QVBoxLayout(self)
        root.setContentsMargins(0, 0, 0, 0)
        root.setSpacing(0)

        # Top bar: clock + hint
        top = QHBoxLayout()
        top.setContentsMargins(40, 32, 40, 0)
        clock = QLabel(self._time_str())
        clock.setStyleSheet(
            f"color: {ON_SURFACE_VARIANT}; font-size: 14px; "
            f"font-family: 'Iosevka Nerd Font'; background: transparent;"
        )
        top.addWidget(clock)
        top.addStretch()
        hint = QLabel("Esc to skip  ·  1 / 2 to choose")
        hint.setStyleSheet(
            f"color: {ON_SURFACE_VARIANT}; font-size: 12px; background: transparent;"
        )
        top.addWidget(hint)
        root.addLayout(top)

        # Update clock every second
        self._clock_label = clock
        self._clock_timer = QTimer(self)
        self._clock_timer.timeout.connect(self._update_clock)
        self._clock_timer.start(1000)

        # Center content
        center = QVBoxLayout()
        center.setAlignment(Qt.AlignmentFlag.AlignCenter)
        center.setSpacing(40)

        title = QLabel("Choose your shell")
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        title.setStyleSheet(
            f"color: {ON_SURFACE}; font-size: 36px; font-weight: 700; "
            f"background: transparent; letter-spacing: 2px;"
        )
        center.addWidget(title)

        subtitle = QLabel("Pick a desktop shell to start this session")
        subtitle.setAlignment(Qt.AlignmentFlag.AlignCenter)
        subtitle.setStyleSheet(
            f"color: {ON_SURFACE_VARIANT}; font-size: 14px; background: transparent;"
        )
        center.addWidget(subtitle)

        # Cards row
        cards = QHBoxLayout()
        cards.setSpacing(40)
        cards.setAlignment(Qt.AlignmentFlag.AlignCenter)
        for name, spec in SHELLS.items():
            card = ShellCard(name, spec)
            cards.addWidget(card)
        center.addLayout(cards)

        # Skip link
        skip = QLabel("Skip — start with no shell")
        skip.setAlignment(Qt.AlignmentFlag.AlignCenter)
        skip.setCursor(Qt.CursorShape.PointingHandCursor)
        skip.setStyleSheet(
            f"color: {ON_SURFACE_VARIANT}; font-size: 12px; background: transparent; "
            f"padding: 8px;"
        )
        skip.mousePressEvent = lambda e: self.close()
        center.addWidget(skip)

        root.addStretch(1)
        root.addLayout(center)
        root.addStretch(1)

        # Bottom: timeout bar
        self._timeout_bar = QFrame()
        self._timeout_bar.setFixedHeight(3)
        self._timeout_bar.setStyleSheet(f"background: {PRIMARY};")
        root.addWidget(self._timeout_bar)

        # Animate timeout bar shrinking
        self._bar_anim = QPropertyAnimation(self._timeout_bar, b"maximumWidth", self)
        self._bar_anim.setDuration(TIMEOUT_MS)
        self._bar_anim.setStartValue(screen.width())
        self._bar_anim.setEndValue(0)
        self._bar_anim.setEasingCurve(QEasingCurve.Type.Linear)
        self._bar_anim.start()

        # Auto-close timer
        self._timer = QTimer(self)
        self._timer.setSingleShot(True)
        self._timer.timeout.connect(self.close)
        self._timer.start(TIMEOUT_MS)

        # Keyboard shortcuts
        # (handled in keyPressEvent)

    def _time_str(self) -> str:
        from datetime import datetime

        return datetime.now().strftime("%H:%M")

    def _update_clock(self) -> None:
        self._clock_label.setText(self._time_str())

    def pick(self, name: str) -> None:
        self._timer.stop()
        self._bar_anim.stop()
        start_shell(name)
        self.close()

    def keyPressEvent(self, event) -> None:
        if event.key() == Qt.Key.Key_Escape:
            self.close()
        elif event.key() == Qt.Key.Key_1:
            self.pick("Caelestia")
        elif event.key() == Qt.Key.Key_2:
            self.pick("Noctalia")
        else:
            super().keyPressEvent(event)


def main() -> int:
    if os.environ.get("HYPRLAND_SESSION_SHELL"):
        return 0

    app = QApplication(sys.argv)
    app.setFont(QFont("Iosevka Nerd Font", 11))
    chooser = Chooser()
    chooser.showFullScreen()
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
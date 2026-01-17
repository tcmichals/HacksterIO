# Minimal Textual port of the curses-based TUI
# Only the main menu and navigation are implemented
# Requires: textual (pip install textual)

from textual.app import App, ComposeResult
from textual.widgets import Static
from textual.containers import Container
from textual.reactive import reactive
from textual import events

MENU_OPTIONS = [
    "[1] PWM Input Monitor",
    "[2] DSHOT Motor Control",
    "[3] NeoPixel Control",
    "[4] On-board LED Control",
    "[q] Quit"
]

class MenuView(Static):
    def compose(self) -> ComposeResult:
        yield Static("[b]Tang9K FPGA Controller[/b]", classes="title")
        for opt in MENU_OPTIONS:
            yield Static(opt)

class MinimalTang9KApp(App):
    CSS = """
    Screen {
        align: center middle;
    }
    .title {
        content-align: center middle;
        margin-bottom: 1;
    }
    """
    mode = reactive("MENU")

    def compose(self) -> ComposeResult:
        yield Container(MenuView(), id="main")

    async def on_key(self, event: events.Key) -> None:
        if self.mode == "MENU":
            if event.key == "1":
                self.mode = "PWM"
                await self.show_message("PWM Input Monitor (not implemented)")
            elif event.key == "2":
                self.mode = "DSHOT"
                await self.show_message("DSHOT Motor Control (not implemented)")
            elif event.key == "3":
                self.mode = "NEO"
                await self.show_message("NeoPixel Control (not implemented)")
            elif event.key == "4":
                self.mode = "LED"
                await self.show_message("On-board LED Control (not implemented)")
            elif event.key == "q":
                await self.action_quit()
        else:
            if event.key == "b":
                self.mode = "MENU"
                await self.show_menu()
            elif event.key == "q":
                await self.action_quit()

    async def show_message(self, msg: str):
        self.query_one("#main").update(Static(msg + "\n[b] Back | [q] Quit"))

    async def show_menu(self):
        self.query_one("#main").update(MenuView())

if __name__ == "__main__":
    MinimalTang9KApp().run()

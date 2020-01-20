use v6.e.PREVIEW;
use Vikna::Widget;
unit class Vikna::Desktop is Vikna::Widget is export;

use Vikna::Events;
use Vikna::Rect;
use Vikna::Utils;

submethod TWEAK {
    self.redraw;
}

method on-screen-resize {
    my $old-w = $.w;
    my $old-h = $.h;
    $.app.screen.setup(:reset);
    $.app.trace: "Desktop resized to ", $.w, " x ", $.h;
    # Do it in two events as screen resize might be handy for a child widget. But otherwise it's a normal resize event.
    self.dispatch: Event::ScreenResize, :$old-w, :$old-h, :$.w, :$.h;
    self.dispatch: Event::Resize, :$old-w, :$old-h, :$.w, :$.h;
}

### Command handlers ###

method cmd-redraw(|) {
    callsame;
    $.trace: "-> screen!";
    $.app.screen.print: 0, 0, $.canvas;
}

### Utility methods ###

# method redraw {
#     $.trace: "DESKTOP REDRAW";
#     $.draw-protect: {
#         $.trace: " -> redrawing, invalidations: ", +@.invalidations;
#         if @.invalidations {
#             $.trace: "DESKTOP self invalidate";
#             $.invalidate if $.auto-clear;
#             my @invalidations = @.invalidations;
#             $.trace: "DESKTOP self clear invalidations";
#             $.clear-invalidations;
#             $.trace: "DISPATCHING DESKTOP REDRAW COMMAND";
#             self.send-command: Event::Cmd::Redraw, @invalidations;
#         }
#     }
# }

# Desktop doesn't allow resize unless through screen resize
method resize(|) { }
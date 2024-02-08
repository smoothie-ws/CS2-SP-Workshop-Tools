package ui;

import haxe.ui.containers.VBox;
import openfl.events.MouseEvent;
import openfl.Lib;

@:build(haxe.ui.ComponentBuilder.build("assets/app-view.xml"))
class AppView extends VBox {
	private var oldPos:openfl.geom.Point;

	private var window = Lib.current.stage.window;

	public function new() {
		super();

		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}

	private function onMouseDown(event:MouseEvent):Void {
		if (event.buttonDown) {
			oldPos = new openfl.geom.Point(event.stageX, event.stageY);
		}
	}

	private function onMouseUp(event:MouseEvent):Void {
		if (!event.buttonDown) {
			oldPos = null;
		}
	}

	private function onMouseMove(event:MouseEvent):Void {
		if (oldPos == null || !event.buttonDown) {
			return;
		} else {
			window.x += Std.int(event.stageX - oldPos.x);
			window.y += Std.int(event.stageY - oldPos.y);
		}
	}
}

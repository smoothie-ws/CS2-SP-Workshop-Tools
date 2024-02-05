package;

import haxe.ui.containers.VBox;
import openfl.events.MouseEvent;
import openfl.Lib;

@:build(haxe.ui.ComponentBuilder.build("assets/app-view.xml"))
class AppView extends VBox {
	private var oldPos:openfl.geom.Point;

	public function new() {
		super();

		this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
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
		if (oldPos == null) {
			return;
		} else {
			Lib.current.stage.window.x += Std.int(event.stageX - oldPos.x);
			Lib.current.stage.window.y += Std.int(event.stageY - oldPos.y);
		}
	}
}

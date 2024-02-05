package ui;

import haxe.ui.containers.VBox;
import motion.Actuate;
import openfl.system.Capabilities;
import openfl.events.MouseEvent;
import openfl.Lib;

@:build(haxe.ui.ComponentBuilder.build("assets/app-view.xml"))
class AppView extends VBox {
	private var oldPos:openfl.geom.Point;

	private var window = Lib.current.stage.window;
	private var windowY:Int;

	public function new() {
		super();

		window.onRestore.add(function() {
			Actuate.tween(window, 0.25, {y: windowY, opacity: 1});
		});

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

	@:bind(minimizeButton, haxe.ui.events.MouseEvent.CLICK)
	private function onMinClick(e:haxe.ui.events.MouseEvent) {
		windowY = window.y;
		Actuate.tween(window, 0.25, {y: Capabilities.screenResolutionY, opacity: 0}).onComplete(onMinimizeComplete);
	}

	@:bind(exitButton, haxe.ui.events.MouseEvent.CLICK)
	private function onExitClick(e:haxe.ui.events.MouseEvent) {
		Actuate.tween(window, 0.25, {opacity: 0}).onComplete(onExitComplete);
	}

	private function onMinimizeComplete():Void {
		window.minimized = true;
	}

	private function onExitComplete():Void {
		window.close();
	}
}

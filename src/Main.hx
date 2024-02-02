package;

import haxe.ui.HaxeUIApp;
#if hl
import hl.UI;
#end

class Main {
	public static function main() {
		#if hl
		UI.closeConsole();
		#end

		var app = new HaxeUIApp();
		app.ready(function() {
			app.addComponent(new AppView());
			app.start();
		});
	}
}

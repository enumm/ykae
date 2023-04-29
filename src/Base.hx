class Base extends hxd.App {
	var fui:h2d.Flow;

	override function init() {
		fui = new h2d.Flow(s2d);
		fui.layout = Vertical;
		fui.verticalSpacing = 5;
		fui.padding = 10;
	}

	function addHorizontalFlow(?name:String, ?parent:h2d.Object):h2d.Flow {
		var flow = new h2d.Flow(parent != null ? parent : fui);
		flow.layout = Horizontal;
		flow.verticalSpacing = 5;
		flow.padding = 10;

		if (name != null) {
			flow.name = name;
		}

		return flow;
	}

	function addVerticalFlow(?name:String, ?parent:h2d.Object):h2d.Flow {
		var flow = new h2d.Flow(parent != null ? parent : fui);
		flow.layout = Vertical;
		flow.verticalSpacing = 5;
		flow.padding = 10;

		if (name != null) {
			flow.name = name;
		}

		return flow;
	}

	function getFont() {
		return hxd.res.DefaultFont.get();
	}

	function addButton(label:String, onClick:Void->Void, ?parent:h2d.Object) {
		var f = new h2d.Flow(parent != null ? parent : fui);
		f.padding = 5;
		f.paddingBottom = 7;
		f.backgroundTile = h2d.Tile.fromColor(0x404040);
		var tf = new h2d.Text(getFont(), f);
		tf.text = label;
		f.enableInteractive = true;
		f.interactive.cursor = Button;
		f.interactive.onClick = function(_) onClick();
		f.interactive.onOver = function(_) f.backgroundTile = h2d.Tile.fromColor(0x606060);
		f.interactive.onOut = function(_) f.backgroundTile = h2d.Tile.fromColor(0x404040);
		return f;
	}

	function addSlider(label:String, get:Void->Float, set:Float->Void, min:Float = 0., max:Float = 1., ?parent:h2d.Object) {
		var f = new h2d.Flow(parent != null ? parent : fui);

		f.horizontalSpacing = 5;

		var tf = new h2d.Text(getFont(), f);
		tf.text = label;
		tf.maxWidth = 80;
		tf.textAlign = Right;

		var sli = new h2d.Slider(100, 10, f);
		sli.minValue = min;
		sli.maxValue = max;
		sli.value = get();

		var tf = new h2d.TextInput(getFont(), f);
		tf.text = "" + hxd.Math.fmt(sli.value);
		sli.onChange = function() {
			set(sli.value);
			tf.text = "" + hxd.Math.fmt(sli.value);
			f.needReflow = true;
		};
		tf.onChange = function() {
			var v = Std.parseFloat(tf.text);
			if (Math.isNaN(v))
				return;
			sli.value = v;
			set(v);
		};
		return sli;
	}

	function addCheck(label:String, get:Void->Bool, set:Bool->Void, ?parent:h2d.Object) {
		var f = new h2d.Flow(parent != null ? parent : fui);

		f.horizontalSpacing = 5;

		var tf = new h2d.Text(getFont(), f);
		tf.text = label;
		tf.maxWidth = 80;
		tf.textAlign = Right;

		var size = 10;
		var b = new h2d.Graphics(f);
		function redraw() {
			b.clear();
			b.beginFill(0x808080);
			b.drawRect(0, 0, size, size);
			b.beginFill(0);
			b.drawRect(1, 1, size - 2, size - 2);
			if (get()) {
				b.beginFill(0xC0C0C0);
				b.drawRect(2, 2, size - 4, size - 4);
			}
		}
		var i = new h2d.Interactive(size, size, b);
		i.onClick = function(_) {
			set(!get());
			redraw();
		};
		redraw();
		return i;
	}

	function addChoice(text, choices, callb:Int->Void, value = 0, ?parent:h2d.Flow) {
		var font = getFont();
		var i = new h2d.Interactive(110, font.lineHeight, parent != null ? parent : fui);
		i.backgroundColor = 0xFF808080;
		(parent != null ? parent : fui).getProperties(i).paddingLeft = 20;

		var t = new h2d.Text(font, i);
		t.maxWidth = i.width;
		t.text = text + ":" + choices[value];
		t.textAlign = Center;

		i.onClick = function(_) {
			value++;
			value %= choices.length;
			callb(value);
			t.text = text + ":" + choices[value];
		};
		i.onOver = function(_) {
			t.textColor = 0xFFFFFF;
		};
		i.onOut = function(_) {
			t.textColor = 0xEEEEEE;
		};
		i.onOut(null);
		return i;
	}

	function addInputInt(label:String, onChange:Int->Void, ?parent:h2d.Object) {
		var f = new h2d.Flow(parent != null ? parent : fui);

		f.horizontalSpacing = 5;

		var tf = new h2d.Text(getFont(), f);
		tf.text = label;
		tf.maxWidth = 80;
		tf.textAlign = Right;

		var input = new h2d.TextInput(getFont(), f);
		input.backgroundColor = 0x80808080;

		input.text = "1";
		input.textColor = 0xF8F8F8;
		input.inputWidth = 50;
		// input.x = input.y = 50;

		input.onFocus = function(_) {
			input.textColor = 0xFFFFFF;
		}
		input.onFocusLost = function(_) {
			input.textColor = 0xF8F8F8;
		}

		input.onChange = function() {
			var val = Std.parseInt(input.text);
			if (val == null) {
				input.text = input.text.substr(0, -1);
			} else {
				if (val > 20) {
					input.text = "20";
					val = 20;
				}

				onChange(val);
			}
		}
	}

	function addText(text = "", ?parent:h2d.Object) {
		var tf = new h2d.Text(getFont(), parent != null ? parent : fui);
		tf.text = text;
		return tf;
	}
}

import uuid.Uuid;
import Data.StateData;
import Data.ObjectData;
import h3d.col.Point;
import hxd.Event;
import h3d.Vector;
import h3d.scene.fwd.DirLight;
import h3d.scene.*;

class Main extends Base {
	var fileControlsFlow:h2d.Flow;
	var newFileControlsFlow:h2d.Flow;
	var newObjectControlsFlow:h2d.Flow;
	var selectNewObjectControlsFlow:h2d.Flow;
	var editObjectControlsFlow:h2d.Flow;
	var floorMesh:Mesh;
	var wallNorthMesh:Mesh;
	var wallEastMesh:Mesh;
	var wallSouthMesh:Mesh;
	var wallWestMesh:Mesh;
	var showNortEastWalls:Bool = true;
	var showSouthWestWalls:Bool = false;
	var snapToGrid = false;
	var cameraControler:CameraController;
	var mousePos:Vector = new Vector(0, 0, 0);
	var roomData:StateData;

	override function init() {
		super.init();

		WebFile.AddFileSelectedListener((concontent) -> {
			loadProject(haxe.Json.parse(concontent));
		});

		fileControlsFlow = addHorizontalFlow("FileControls");
		newFileControlsFlow = addVerticalFlow("NewControls");
		newObjectControlsFlow = addVerticalFlow("NewObject");
		selectNewObjectControlsFlow = addVerticalFlow("SelectNewObject");
		editObjectControlsFlow = addVerticalFlow("EditObject");

		addFileControls();

		addButton("new object", () -> {
			showNewObject();
		}, newObjectControlsFlow);

		engine.backgroundColor = 0xDCCAE4;

		newProject(10, 10);
	}

	// ui
	function addFileControls() {
		addButton("new", () -> {
			showNewOptions();
		}, fileControlsFlow);

		addButton("load", () -> {
			WebFile.SelectFile();
		}, fileControlsFlow);

		addButton("save", () -> {
			WebFile.SaveFile(haxe.Json.stringify(roomData));
		}, fileControlsFlow);

		addText(" ", fileControlsFlow);

		addButton("room settings", () -> {
			showRoomSettings();
		}, fileControlsFlow);

		addButton("reset camera", () -> {
			s3d.camera.target.set(0, 0, 0);
			s3d.camera.pos.set(25, 25, 10);
			cameraControler.loadFromCamera();
		}, fileControlsFlow);

		addText(" Walls:", fileControlsFlow);

		addCheck("North/East", () -> {
			return showNortEastWalls;
		}, (val) -> {
			showNortEastWalls = val;
			wallNorthMesh.visible = val;
			wallEastMesh.visible = val;
		}, fileControlsFlow);

		addCheck("South/West", () -> {
			return showSouthWestWalls;
		}, (val) -> {
			showSouthWestWalls = val;
			wallSouthMesh.visible = val;
			wallWestMesh.visible = val;
		}, fileControlsFlow);

		addCheck("snap to grid", () -> {
			return snapToGrid;
		}, (val) -> {
			snapToGrid = val;
		}, fileControlsFlow);
	}

	function showNewOptions() {
		removeAllUISelections();
		var width:Int;
		var lenght:Int;

		addInputInt("room width", (value) -> {
			width = value;
		}, newFileControlsFlow);
		addInputInt("room lenght", (value) -> {
			lenght = value;
		}, newFileControlsFlow);
		var buttonFlow = addHorizontalFlow(newFileControlsFlow);
		addButton("ok", () -> {
			removeAllUISelections();
			newProject(width, lenght);
		}, buttonFlow);
		addButton("cancel", () -> {
			removeAllUISelections();
		}, buttonFlow);
	}

	function showNewObject() {
		removeAllUISelections();

		for (obj in RoomObjects.objects) {
			addButton(obj.name, () -> {
				addNewRoomObject(obj);
				removeAllUISelections();
			}, selectNewObjectControlsFlow);
		}

		addText(" ", selectNewObjectControlsFlow);
		addButton("cancel", () -> {
			removeAllUISelections();
		}, selectNewObjectControlsFlow);
	}

	function removeShowNewObject() {
		selectNewObjectControlsFlow.removeChildren();
		selectNewObjectControlsFlow.reflow();
	}

	function editSelectedObject(obj:Mesh) {
		removeAllUISelections();

		var materials = obj.getMaterials();
		var color:Vector = materials[0].color.clone();

		inline function setRoomData() {
			if (roomData.objects.exists(obj.name)) {
				var dataObj = roomData.objects.get(obj.name);
				dataObj.color = color;
				dataObj.rotation = obj.getRotationQuat().toEuler();
				dataObj.scale = new Vector(obj.scaleX, obj.scaleY, obj.scaleZ);
			}
		}

		inline function setObjColor() {
			for (mat in materials) {
				mat.color = color;
			}

			setRoomData();
		}

		addText("color", editObjectControlsFlow);

		addSlider("R", () -> {
			return color.x;
		}, (val) -> {
			color.x = val;
			setObjColor();
		}, 0, 1, editObjectControlsFlow);
		addSlider("G", () -> {
			return color.y;
		}, (val) -> {
			color.y = val;
			setObjColor();
		}, 0, 1, editObjectControlsFlow);
		addSlider("B", () -> {
			return color.z;
		}, (val) -> {
			color.z = val;
			setObjColor();
		}, 0, 1, editObjectControlsFlow);

		addText("scale", editObjectControlsFlow);

		addSlider("X", () -> {
			return obj.scaleX;
		}, (val) -> {
			obj.scaleX = val;
			setRoomData();
		}, 0.5, 10, editObjectControlsFlow);
		addSlider("Y", () -> {
			return obj.scaleY;
		}, (val) -> {
			obj.scaleY = val;
			setRoomData();
		}, 0.5, 10, editObjectControlsFlow);
		addSlider("Z", () -> {
			return obj.scaleZ;
		}, (val) -> {
			obj.scaleZ = val;
			setRoomData();
		}, 0.5, 10, editObjectControlsFlow);

		addText("rotate", editObjectControlsFlow);

		addSlider("X", () -> {
			return obj.getRotationQuat().toEuler().x;
		}, (val) -> {
			var rotation = obj.getRotationQuat().toEuler();
			obj.setRotation(val, rotation.y, rotation.z);
			setRoomData();
		}, 0, Math.PI * 2, editObjectControlsFlow);

		addSlider("Y", () -> {
			return obj.getRotationQuat().toEuler().y;
		}, (val) -> {
			var rotation = obj.getRotationQuat().toEuler();
			obj.setRotation(rotation.x, val, rotation.z);
			setRoomData();
		}, 0, Math.PI * 2, editObjectControlsFlow);

		addSlider("Z", () -> {
			return obj.getRotationQuat().toEuler().z;
		}, (val) -> {
			var rotation = obj.getRotationQuat().toEuler();
			obj.setRotation(rotation.x, rotation.y, val);
			setRoomData();
		}, 0, Math.PI * 2, editObjectControlsFlow);

		var buttonsFlow = addHorizontalFlow("EditFlowButtons", editObjectControlsFlow);

		addButton("remove", () -> {
			roomData.objects.remove(obj.name);
			obj.remove();
			removeAllUISelections();
		}, buttonsFlow);

		addText(" ", buttonsFlow);

		addButton("close", () -> {
			removeAllUISelections();
		}, buttonsFlow);

		addMovementAxis(obj);
	}

	function removeEditSelectedObject() {
		editObjectControlsFlow.removeChildren();
		editObjectControlsFlow.reflow();
		removeInteractAxis();
	}

	function showRoomSettings() {
		removeAllUISelections();
		var wallColor:Vector = wallNorthMesh.material.color.clone();
		var floorColor:Vector = floorMesh.material.color.clone();

		inline function setWallColor() {
			roomData.wallColor = wallColor;
			wallNorthMesh.material.color = wallColor;
			wallEastMesh.material.color = wallColor;
			wallSouthMesh.material.color = wallColor;
			wallWestMesh.material.color = wallColor;
		}

		inline function setFloorColor() {
			roomData.floorColor = floorColor;
			floorMesh.material.color = floorColor;
		}

		addText("wall color", editObjectControlsFlow);

		addSlider("R", () -> {
			return wallColor.x;
		}, (val) -> {
			wallColor.x = val;
			setWallColor();
		}, 0, 1, editObjectControlsFlow);
		addSlider("G", () -> {
			return wallColor.y;
		}, (val) -> {
			wallColor.y = val;
			setWallColor();
		}, 0, 1, editObjectControlsFlow);
		addSlider("B", () -> {
			return wallColor.z;
		}, (val) -> {
			wallColor.z = val;
			setWallColor();
		}, 0, 1, editObjectControlsFlow);

		addText("floor color", editObjectControlsFlow);

		addSlider("R", () -> {
			return floorColor.x;
		}, (val) -> {
			floorColor.x = val;
			setFloorColor();
		}, 0, 1, editObjectControlsFlow);
		addSlider("G", () -> {
			return floorColor.y;
		}, (val) -> {
			floorColor.y = val;
			setFloorColor();
		}, 0, 1, editObjectControlsFlow);
		addSlider("B", () -> {
			return floorColor.z;
		}, (val) -> {
			floorColor.z = val;
			setFloorColor();
		}, 0, 1, editObjectControlsFlow);

		addButton("close", () -> {
			removeAllUISelections();
		}, editObjectControlsFlow);
	}

	function removeAllUISelections() {
		// new project
		newFileControlsFlow.removeChildren();
		newFileControlsFlow.reflow();
		// new object
		removeShowNewObject();
		// objectEdit
		removeEditSelectedObject();
	}

	// room objects
	function newProject(width:Int, lenght:Int) {
		s3d.removeChildren();

		roomData = {
			roomLenght: lenght,
			roomWidth: width,
			wallColor: new Vector(1, 1, 1),
			floorColor: new Vector(1, 1, 1),
			objects: new Map<String, ObjectData>()
		};

		var light = new h3d.scene.fwd.DirLight(new h3d.Vector(-0.3, -0.2, -1), s3d);
		light.enableSpecular = true;
		s3d.lightSystem.ambientLight.set(0.3, 0.3, 0.3);

		s3d.camera.target.set(0, 0, 0);
		s3d.camera.pos.set(25, 25, 10);

		cameraControler = new h3d.scene.CameraController(s3d);
		cameraControler.loadFromCamera();

		floorMesh = addCubePrimitive(new Vector(width + 0.1, lenght + 0.1, 0.1), new Vector(-0.1, -0.1, -0.1), s3d);
		wallNorthMesh = addCubePrimitive(new Vector(0.1, lenght + 0.1, 5), new Vector(-0.1, -0.1, -0.1), s3d);
		wallEastMesh = addCubePrimitive(new Vector(width, 0.1, 5), new Vector(0, -0.1, -0.1), s3d);

		wallSouthMesh = addCubePrimitive(new Vector(0.1, lenght + 0.1, 5), new Vector(0, -0.1, -0.1), s3d);
		wallSouthMesh.x = width;
		wallWestMesh = addCubePrimitive(new Vector(width, 0.1, 5), new Vector(0, 0, -0.1), s3d);
		wallWestMesh.y = lenght - 0.1;

		if (!showNortEastWalls) {
			wallNorthMesh.visible = false;
			wallEastMesh.visible = false;
		}

		if (!showSouthWestWalls) {
			wallSouthMesh.visible = false;
			wallWestMesh.visible = false;
		}
	}

	function loadProject(state:StateData) {
		newProject(state.roomWidth, state.roomLenght);
		roomData = state;

		wallNorthMesh.material.color = state.wallColor;
		wallEastMesh.material.color = state.wallColor;
		wallSouthMesh.material.color = state.wallColor;
		wallNorthMesh.material.color = state.wallColor;
		floorMesh.material.color = state.floorColor;

		for (object in state.objects) {
			if (RoomObjects.objects.exists(object.type)) {
				var mesh = addNewRoomObject(RoomObjects.objects.get(object.type), false);
				mesh.name = object.name;
				mesh.setPosition(object.position.x, object.position.y, object.position.z);
				mesh.setRotation(object.rotation.x, object.rotation.y, object.rotation.z);
				mesh.scaleX = object.scale.x;
				mesh.scaleY = object.scale.y;
				mesh.scaleZ = object.scale.z;

				for (mat in mesh.getMaterials()) {
					mat.color = object.color;
				}
			}
		}
	}

	function addNewRoomObject(obj:{name:String, primitives:Array<{type:RoomObjects.PrimitiveType, size:Point, translation:Point}>},
			addToData:Bool = true):Mesh {
		var mesh:Mesh = null;

		for (prim in obj.primitives) {
			if (mesh == null) {
				mesh = addCubePrimitive(new Vector(prim.size.x, prim.size.y, prim.size.z),
					new Vector(prim.translation.x, prim.translation.y, prim.translation.z));
				if (addToData) {
					mesh.name = Uuid.nanoId();
					roomData.objects.set(mesh.name, {
						name: mesh.name,
						type: obj.name,
						position: new Point(0, 0, 0),
						rotation: new Vector(),
						scale: new Vector(1, 1, 1),
						color: new Vector(1, 1, 1)
					});
				}
			} else {
				addCubePrimitive(new Vector(prim.size.x, prim.size.y, prim.size.z), new Vector(prim.translation.x, prim.translation.y, prim.translation.z),
					mesh);
			}
		}

		var interact = new h3d.scene.Interactive(mesh.getCollider(), s3d);
		initInteractObject(interact, mesh);

		return mesh;
	}

	function addCubePrimitive(size:Vector, translation:Vector, ?parent:Object):Mesh {
		var cube = new h3d.prim.Cube(size.x, size.y, size.z);
		cube.translate(translation.x, translation.y, translation.z);
		cube.unindex();
		cube.addNormals();
		cube.addUVs();
		var cubeMesh = new h3d.scene.Mesh(cube, parent != null ? parent : s3d);
		cubeMesh.material.mainPass.enableLights = true;
		cubeMesh.material.shadows = true;
		return cubeMesh;
	}

	// interactive
	function initInteractObject(i:h3d.scene.Interactive, m:h3d.scene.Mesh) {
		var materials = m.getMaterials();
		var color = m.material.color.clone();

		i.bestMatch = true;
		i.onOver = function(e:hxd.Event) {
			color = m.material.color.clone();

			for (mat in materials) {
				mat.color.set(0, 1, 0);
			}
		};
		i.onOut = function(e:hxd.Event) {
			for (mat in materials) {
				mat.color.load(color);
			}
		};
		i.onClick = function(e:Event) {
			for (mat in materials) {
				mat.color.load(color);
			}

			editSelectedObject(m);
		}
	}

	function addMovementAxis(obj:Mesh) {
		var axisX = addCubePrimitive(new Vector(5, .05, .05), new Vector(0, 0, 0), obj);
		axisX.name = "AxisX";
		axisX.material.color.setColor(0xFF0000);
		axisX.setPosition(obj.x, obj.y, obj.z);
		axisX.material.mainPass.enableLights = false;
		axisX.material.shadows = false;
		axisX.ignoreParentTransform = true;

		var axisY = addCubePrimitive(new Vector(.05, 5, .05), new Vector(0, 0, 0), obj);
		axisY.name = "AxisY";
		axisY.material.color.setColor(0x00FF00);
		axisY.setPosition(obj.x, obj.y, obj.z);
		axisY.material.mainPass.enableLights = false;
		axisY.material.shadows = false;
		axisY.ignoreParentTransform = true;

		var axisZ = addCubePrimitive(new Vector(.05, .05, 5), new Vector(0, 0, 0), obj);
		axisZ.name = "AxisZ";
		axisZ.material.color.setColor(0x0000FF);
		axisZ.setPosition(obj.x, obj.y, obj.z);
		axisZ.material.mainPass.enableLights = false;
		axisZ.material.shadows = false;
		axisZ.ignoreParentTransform = true;

		var oldX:Float = null;
		var oldY:Float = null;
		var oldZ:Float = null;

		var tempPosX:Float = obj.x;
		var tempPosY:Float = obj.y;
		var tempPosZ:Float = obj.z;

		inline function updateGameDataWithPosition() {
			if (roomData.objects.exists(obj.name)) {
				roomData.objects.get(obj.name).position = new Point(obj.x, obj.y, obj.z);
			}
		}

		initInteractAxis("InteractiveAxisX", axisX, (e:Event) -> {
			var ray = s3d.camera.rayFromScreen(e.relX, e.relY);
			var rayDir = ray.getDir();
			var distance = ray.getPos().distance(rayDir);

			if (oldX == null) {
				oldX = rayDir.x;
			}

			tempPosX -= ((oldX - rayDir.x) * distance);

			if (snapToGrid) {
				var x = Math.round(tempPosX * 2.0) / 2.0;
				obj.x = x;
				axisX.x = x;
				axisY.x = x;
				axisZ.x = x;
			} else {
				obj.x = tempPosX;
				axisX.x = tempPosX;
				axisY.x = tempPosX;
				axisZ.x = tempPosX;
			}

			updateGameDataWithPosition();

			oldX = rayDir.x;
		}, () -> {
			oldX = null;
		});

		initInteractAxis("InteractiveAxisY", axisY, (e:Event) -> {
			var ray = s3d.camera.rayFromScreen(e.relX, e.relY);
			var rayDir = ray.getDir();
			var distance = ray.getPos().distance(rayDir);

			if (oldY == null) {
				oldY = rayDir.y;
			}

			tempPosY -= ((oldY - rayDir.y) * distance);

			if (snapToGrid) {
				var y = Math.round(tempPosY * 2.0) / 2.0;
				obj.y = y;
				axisX.y = y;
				axisY.y = y;
				axisZ.y = y;
			} else {
				obj.y = tempPosY;
				axisX.y = tempPosY;
				axisY.y = tempPosY;
				axisZ.y = tempPosY;
			}

			updateGameDataWithPosition();

			oldY = rayDir.y;
		}, () -> {
			oldY = null;
		});

		initInteractAxis("InteractiveAxisZ", axisZ, (e:Event) -> {
			var ray = s3d.camera.rayFromScreen(e.relX, e.relY);
			var rayDir = ray.getDir();
			var distance = ray.getPos().distance(rayDir);

			if (oldZ == null) {
				oldZ = rayDir.z;
			}

			tempPosZ -= ((oldZ - rayDir.z) * distance);

			if (snapToGrid) {
				var z = Math.round(tempPosZ * 2.0) / 2.0;
				obj.z = z;
				axisX.z = z;
				axisY.z = z;
				axisZ.z = z;
			} else {
				obj.z = tempPosZ;
				axisX.z = tempPosZ;
				axisY.z = tempPosZ;
				axisZ.z = tempPosZ;
			}

			updateGameDataWithPosition();

			oldZ = rayDir.z;
		}, () -> {
			oldZ = null;
		});
	}

	function initInteractAxis(name:String, mesh:h3d.scene.Mesh, onChange:Event->Void, onRelease:Void->Void) {
		var i = new h3d.scene.Interactive(mesh.getCollider(), s3d);
		i.name = name;
		var color = mesh.material.color.clone();
		i.bestMatch = true;
		i.onOver = function(e:hxd.Event) {
			mesh.material.color.set(0, 1, 0);
		};
		i.onOut = function(e:hxd.Event) {
			mesh.material.color.load(color);
		};
		i.onPush = function(e:Event) {
			hxd.Window.getInstance().addEventTarget(onChange);
		};
		i.onRelease = function(e:Event) {
			onRelease();
			hxd.Window.getInstance().removeEventTarget(onChange);
		};
	}

	function removeInteractAxis() {
		s3d.getObjectByName("AxisX").remove();
		s3d.getObjectByName("AxisY").remove();
		s3d.getObjectByName("AxisZ").remove();
		s3d.getObjectByName("InteractiveAxisX").remove();
		s3d.getObjectByName("InteractiveAxisY").remove();
		s3d.getObjectByName("InteractiveAxisZ").remove();
	}

	function onEvent(event:hxd.Event) {
		mousePos.x = event.relX;
		mousePos.y = event.relY;
	}

	static function main() {
		hxd.Res.initEmbed();
		new Main();
	}
}

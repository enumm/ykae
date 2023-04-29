import h3d.Vector;
import h3d.col.Point;

typedef StateData = {
	roomLenght:Int,
	roomWidth:Int,
	wallColor:Vector,
	floorColor:Vector,
	objects:Map<String, ObjectData>
}

typedef ObjectData = {
	name:String,
	type:String,
	position:Point,
	color:Vector,
	scale:Vector,
	rotation:Vector
}

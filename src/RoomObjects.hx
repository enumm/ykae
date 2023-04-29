import h2d.col.Point;

enum PrimitiveType {
	Cube;
	Sphere;
}

class RoomObjects {
	public static var objects = [
		"sofa" => {
			name: "sofa",
			primitives: [
				{
					type: PrimitiveType.Cube,
					size: new h3d.col.Point(3, 1, 0.5),
					translation: new h3d.col.Point(0, 0, 0)
				},
				{
					type: PrimitiveType.Cube,
					size: new h3d.col.Point(0.5, 0.7, 0.5),
					translation: new h3d.col.Point(0, 0.3, 0.5)
				},
				{
					type: PrimitiveType.Cube,
					size: new h3d.col.Point(0.5, 0.7, 0.5),
					translation: new h3d.col.Point(2.5, 0.3, 0.5)
				},
				{
					type: PrimitiveType.Cube,
					size: new h3d.col.Point(3, 0.3, 1),
					translation: new h3d.col.Point(0, 0, 0.5)
				}
			]
		},
		"chair" => {
			name: "chair",
			primitives: [
				{
					type: PrimitiveType.Cube,
					size: new h3d.col.Point(0.1, 0.1, 0.4),
					translation: new h3d.col.Point(0, 0, 0)
				},
				{
					type: PrimitiveType.Cube,
					size: new h3d.col.Point(0.1, 0.1, 0.4),
					translation: new h3d.col.Point(0.4, 0, 0)
				},
				{
					type: PrimitiveType.Cube,
					size: new h3d.col.Point(0.1, 0.1, 0.4),
					translation: new h3d.col.Point(0, 0.4, 0)
				},
				{
					type: PrimitiveType.Cube,
					size: new h3d.col.Point(0.1, 0.1, 0.4),
					translation: new h3d.col.Point(0.4, 0.4, 0)
				},
				{
					type: PrimitiveType.Cube,
					size: new h3d.col.Point(0.5, 0.5, 0.1),
					translation: new h3d.col.Point(0, 0, 0.4)
				},
				{
					type: PrimitiveType.Cube,
					size: new h3d.col.Point(0.5, 0.1, 0.5),
					translation: new h3d.col.Point(0, 0, 0.5)
				}
			]
		},
		"table" => {
			name: "table",
			primitives: [
				{
					type: PrimitiveType.Cube,
					size: new h3d.col.Point(0.1, 0.1, 0.7),
					translation: new h3d.col.Point(0, 0, 0)
				},
				{
					type: PrimitiveType.Cube,
					size: new h3d.col.Point(0.1, 0.1, 0.7),
					translation: new h3d.col.Point(0, 1, 0)
				},
				{
					type: PrimitiveType.Cube,
					size: new h3d.col.Point(0.1, 0.1, 0.7),
					translation: new h3d.col.Point(2, 0, 0)
				},
				{
					type: PrimitiveType.Cube,
					size: new h3d.col.Point(0.1, 0.1, 0.7),
					translation: new h3d.col.Point(2, 1, 0)
				},
				{
					type: PrimitiveType.Cube,
					size: new h3d.col.Point(2.1, 1.1, 0.1),
					translation: new h3d.col.Point(0, 0, 0.7)
				}
			]
		}
	];
}

import 'dart:html';

final CanvasRenderingContext2D ctx =
  (querySelector("#canvas") as CanvasElement).context2D;


ButtonElement submitt;
TextAreaElement input;

void getPolygons(Event e) {
  input.text();
}


void main() {
  querySelector('#submitt');
  submitt = querySelector('#generateButton');
  input = querySelector('#input');
  submitt.onClick.listen(getPolygons);
  ctx.moveTo(100, 100);
  ctx.lineTo(0, 200);
  ctx.lineTo(100, 300);
  ctx.lineTo(400, 300);
  ctx.lineTo(300, 200);
  ctx.lineTo(100, 100);
  ctx.closePath();
  ctx.lineWidth = 0;
  ctx.strokeStyle = 'black';
  ctx.fillStyle = '#0000ff';
  ctx.fill();
}
function getTime() {
	return new Date().getTime() / 1000
}

function draw(image, x = 0, y = 0, r = 0, sx = 1, sy = 1, ox = 0, oy = 0) {
	ctx.save()
	ctx.translate(x, y)
	ctx.scale(sx, sy)
	ctx.translate(ox, oy)
	ctx.rotate(r)
	ctx.drawImage(image, -ox, -oy)
	ctx.restore()
}

const canvas = document.getElementById("vsrg-preview")
const ctx = canvas.getContext("2d")

const arrow_image = new Image()
arrow_image.src = "static/images/home/arrow.webp"

const key_image = new Image()
key_image.src = "static/images/home/key.webp"

var iw = 128
var ih = 128
var ox = iw / 2
var oy = ih / 2

const note_image_transform = [
	{ x: 0, r: 0, ox: ox, oy: oy },
	{ x: iw, r: Math.PI / 2, ox: ox, oy: oy },
	{ x: iw * 2, r: -Math.PI / 2, ox: ox, oy: oy },
	{ x: iw * 3, r: Math.PI, ox: ox, oy: oy }
]

iw = 128
ih = 128
ox = iw / 2
oy = ih / 2

const key_image_transform = [
	{ x: 0, r: 0, ox: ox, oy: oy },
	{ x: iw, r: Math.PI / 2, ox: ox, oy: oy },
	{ x: iw * 2, r: -Math.PI / 2, ox: ox, oy: oy },
	{ x: iw * 3, r: Math.PI, ox: ox, oy: oy }
]

const Note = class {
	constructor(time, column) {
		this.time = time
		this.column = column
	}
}

function getRandomIntInclusive(min, max) {
	const minCeiled = Math.ceil(min);
	const maxFloored = Math.floor(max);
	return Math.floor(Math.random() * (maxFloored - minCeiled + 1) + minCeiled); // The maximum is inclusive and the minimum is inclusive
}

const notes = []

function generateStream(time, note_count) {
	const bpm = 200
	const frac = 4
	const time_between = (60 / bpm) / frac

	var prev_hand = "left"

	for (i = 0; i < note_count; i++) {
		var column = 0

		if (prev_hand == "left") {
			column = getRandomIntInclusive(2, 3)
			prev_hand = "right"
			right_prev_column = column
		}
		else {
			column = getRandomIntInclusive(0, 1)
			prev_hand = "left"
		}
		notes.push(new Note(time + i * time_between, column))
	}
}

generateStream(0, 20)

const start_time = getTime()
const scroll_speed = 1200
const hit_position = 690
const min_time = 1
const max_time = 0
var start_draw_index = 0
var current_note_index = 0

function loop() {
	ctx.reset()

	const theme = localStorage.getItem("theme")

	if (theme == "dark") {
		ctx.filter = "opacity(0.8) invert(1)"
	}
	else {
		ctx.filter = "opacity(0.8) invert(0)"
	}

	ctx.clearRect(0, 0, canvas.width, canvas.height)
	const current_time = getTime() - start_time

	for (i = current_note_index; i < notes.length; i++) {
		if (current_time < notes[i].time - min_time)
			break
		current_note_index = i + 1
	}

	for (i = start_draw_index; i < current_note_index; i++) {
		const note = notes[i];

		if (current_time > note.time + max_time) {
			start_draw_index = i + 1
			continue
		}

		const delta_time = current_time - note.time
		const scaled_delta_time = delta_time * scroll_speed
		const y = scaled_delta_time + hit_position

		const t = note_image_transform[note.column]
		draw(arrow_image, t.x, y, t.r, 1, 1, t.ox, t.oy)
	}

	for (i = 0; i < 4; i++) {
		const t = key_image_transform[i]
		draw(key_image, t.x, hit_position, t.r, 1, 1, t.ox, t.oy)
	}

	if (current_note_index == notes.length) {
		const last = notes[notes.length - 1].time
		const lastlast = notes[notes.length - 2].time
		generateStream(last + (last - lastlast), 20)
	}

	requestAnimationFrame(loop)
}

loop()

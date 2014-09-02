
var canvas = document.getElementById('myCanvas');
var context = canvas.getContext('2d');
var log = document.getElementById('log');

var x;
var y;
var yMax;
var imageObj = new Image();
imageObj.onload = function(){
	x = canvas.width;
	yMax = canvas.height - imageObj.height;
	y = yMax;
}
imageObj.src = './images/myPNG.png';

var IntervalIDstats = null;
var IntervalIDx = null;
var IntervalIDy = null;
var IntervalIDfps = null;

var isOn = false;
var goDown = false;
var isOnY = false;

var speed = 1;
var refreshRate = 1;
var jumpSpeed = 4;
var jumpSpeedMod = 4;
var frameCount = 1;
var myFPS = 1;

var out = '';

function startCanvas()
{
	if(isOn === false) {
		IntervalIDx = setInterval(moveImg, refreshRate);
		IntervalIDstats = setInterval(printStats, refreshRate);
		IntervalIDfps = setInterval(findFPS, 100);
		
	}
	isOn = true;

}

function stopCanvas()
{
	if(isOn === true) {
		isOn = false;
		clearInterval(IntervalIDx);
		clearInterval(IntervalIDy);
		clearInterval(IntervalIDstats);
		clearInterval(IntervalIDfps);
		speed = 1;
		refreshRate = 1;
		x = canvas.width;
		yMax = canvas.height - imageObj.height - 1;
		y = yMax;
		goDown = false;
		isOnY = false;
		jumpSpeed = 4;
		jumpSpeedMod = 4;
		out = '';
		context.clearRect(0, 0, canvas.width, canvas.height);
		
	}
	

}

function moveImg()
{
	context.clearRect(0, 0, canvas.width, canvas.height);
	x = x - speed;
	if(speed > 0){
		if(x < 0 - imageObj.width) {
			x=canvas.width - imageObj.width;
		}
		
		if(x < 0) {
			// draw duplicate
			context.drawImage(imageObj, canvas.width + x, y);
		}
		

	} else if(speed < 0){
		if(x > canvas.width) {
			x = 0;
		}
		
		if(x > canvas.width - imageObj.width) {
			// draw duplicate
			context.drawImage(imageObj,  x - canvas.width, y);
		}
		
	} else {
		alert('speed is zero somehow');
	}
	context.drawImage(imageObj, x, y);
	frameCount = frameCount + 1;
	
}

function moarFaster()
{
	speed = speed * 2;
}
 
function moarSlower()
{
	speed = speed / 2;
}
 
function switchDirection()
{
	speed = speed * -1;
}

function doJump()
{
	if(isOnY === false) IntervalIDy = setInterval(jumpImg, refreshRate);
	isOnY = true;
}

function doRotate()
{

}

function jumpImg()
{

	if(goDown === true) {
		y = y + jumpSpeed;
		if(y >= yMax) {
			clearInterval(IntervalIDy);
			isOnY = false;
			goDown = false;
			jumpSpeed = 4;
		}
	} else if(goDown === false) {
		y = y - jumpSpeed;
		if(y <= yMax / 2) goDown = true;
	} else {
		alert('not sure what happened here');
	}
	jumpSpeed = (y / (yMax)) * jumpSpeedMod;
}

function printStats()
{
	
	document.getElementById('out_FPS').innerHTML = myFPS;
	document.getElementById('out_x').innerHTML = x;
	document.getElementById('out_y').innerHTML = y;
	document.getElementById('out_yMax').innerHTML = yMax;
	document.getElementById('out_isOn').innerHTML = isOn;
	document.getElementById('out_speed').innerHTML = speed;
	document.getElementById('out_refreshRate').innerHTML = refreshRate;
	document.getElementById('out_goDown').innerHTML = goDown;
	document.getElementById('out_isOnY').innerHTML = isOnY;
	document.getElementById('out_jumpSpeed').innerHTML = jumpSpeed;
	document.getElementById('out_jumpSpeedMod').innerHTML = jumpSpeedMod;
}

function findFPS(){
	myFPS = frameCount * 10;
	frameCount = 1;
}

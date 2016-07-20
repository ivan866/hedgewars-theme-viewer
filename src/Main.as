package {
	import com.greensock.data.TweenMaxVars;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.GraphicsBitmapFill;
	import flash.display.GradientType;;
	import flash.display.Loader;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.PixelSnapping;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.textures.RectangleTexture;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import flash.events.Event;
	import flash.events.TimerEvent;

	import flash.filesystem.*;

	import flash.net.URLRequest;

	import flash.utils.Timer;


	import com.bit101.components.Accordion;
	import com.greensock.*;
	import org.aswing.ASColor;
	import starling.utils.Color;



	/**
	 * ...
	 * @author ivan866
	 */


	/* TODO
	 * accordion component
	 * 'Default' checkbox
	 * No image, any size, transparency, animation allowed tags
	 *
	 * SD mode switch on top
	 *
	 * List component for objects and sprays
	 * files detected by config or Object and Spray prefix
	 * same size preview for all images
	 *
	 * generate button for each particle type
	 *
	 * live theme parts selection is tied with accordion
	 * place barrels, first aid, crates, utilities and mines on map
	 * also girders, mudballs, bridges, tunnels and explosion holes
	 *
	 * validity check menu: absent files, image sizes, config quantities
	 * validity warning on save
	 *
	 * COMMENT
	 * ThemeViewer for Windows
	 * objects are detected by filename
	 * defaults can be edited in settings.xml
	 */


	public class Main extends Sprite {

		public function Main() {
			var windowMenu:NativeMenu = new NativeMenu();

			var fileSubmenu:NativeMenu = new NativeMenu();
			var openDirMenuItem:NativeMenuItem = new NativeMenuItem("Open dir...");
				openDirMenuItem.name = "openDir";
				fileSubmenu.addItem(openDirMenuItem);
			var openHWPMenuItem:NativeMenuItem = new NativeMenuItem("Open HWP...");
				openHWPMenuItem.name = "openHWP";
				fileSubmenu.addItem(openHWPMenuItem);
			var sepMenuItem:NativeMenuItem = new NativeMenuItem("", true);
				fileSubmenu.addItem(sepMenuItem);

			var refreshMenuItem:NativeMenuItem = new NativeMenuItem("Refresh");
				refreshMenuItem.name = "refresh";
				fileSubmenu.addItem(refreshMenuItem);
				sepMenuItem = new NativeMenuItem("", true);
				fileSubmenu.addItem(sepMenuItem);

			var saveCfgMenuItem:NativeMenuItem = new NativeMenuItem("Save theme.cfg");
				saveCfgMenuItem.name = "saveCfg";
				fileSubmenu.addItem(saveCfgMenuItem);
			var copyToMenuItem:NativeMenuItem = new NativeMenuItem("Copy to...");
				copyToMenuItem.name = "copyTo";
				fileSubmenu.addItem(copyToMenuItem);
			var makeHWPMenuItem:NativeMenuItem = new NativeMenuItem("Make HWP");
				makeHWPMenuItem.name = "makeHWP";
				fileSubmenu.addItem(makeHWPMenuItem);
				sepMenuItem = new NativeMenuItem("", true);
				fileSubmenu.addItem(sepMenuItem);

			var printMenuItem:NativeMenuItem = new NativeMenuItem("Print...");
				printMenuItem.name = "print";
				fileSubmenu.addItem(printMenuItem);
			var screenshotMenuItem:NativeMenuItem = new NativeMenuItem("Screenshot");
				screenshotMenuItem.name = "screenshot";
				fileSubmenu.addItem(screenshotMenuItem);
				sepMenuItem = new NativeMenuItem("", true);
				fileSubmenu.addItem(sepMenuItem);

			var exitMenuItem:NativeMenuItem = new NativeMenuItem("Exit");
				exitMenuItem.name = "exit";
				fileSubmenu.addItem(exitMenuItem);
			windowMenu.addSubmenu(fileSubmenu, "File");


			var editSubmenu:NativeMenu = new NativeMenu();
			var undoMenuItem:NativeMenuItem = new NativeMenuItem("Undo");
				undoMenuItem.name = "undo";
				editSubmenu.addItem(undoMenuItem);
			var redoMenuItem:NativeMenuItem = new NativeMenuItem("Redo");
				redoMenuItem.name = "redo";
				editSubmenu.addItem(redoMenuItem);
			windowMenu.addSubmenu(editSubmenu, "Edit");


			var helpSubmenu:NativeMenu = new NativeMenu();
			var manualMenuItem:NativeMenuItem = new NativeMenuItem("Manual");
				manualMenuItem.name = "manual";
				helpSubmenu.addItem(manualMenuItem);
			var tipsMenuItem:NativeMenuItem = new NativeMenuItem("Tips");
				tipsMenuItem.name = "tips";
				helpSubmenu.addItem(tipsMenuItem);
				sepMenuItem = new NativeMenuItem("", true);
				helpSubmenu.addItem(sepMenuItem);

			var linksSubmenu:NativeMenu = new NativeMenu();
			var linkHWThemeFilesMenuItem:NativeMenuItem = new NativeMenuItem("hedgewars.org/kb/ThemeFiles");
				linkHWThemeFilesMenuItem.name = "HWThemeFiles";
				linksSubmenu.addItem(linkHWThemeFilesMenuItem);
			var linkHWThemeEditorMenuItem:NativeMenuItem = new NativeMenuItem("hedgewars.org/node/6435");
				linkHWThemeEditorMenuItem.name = "HWThemeEditor";
				linksSubmenu.addItem(linkHWThemeEditorMenuItem);
			var linkUnit22MenuItem:NativeMenuItem = new NativeMenuItem("hh.unit22.org");
				linkUnit22MenuItem.name = "unit22";
				linksSubmenu.addItem(linkUnit22MenuItem);
			var linkHWGitHubMenuItem:NativeMenuItem = new NativeMenuItem("github.com/hedgewars/hw");
				linkHWGitHubMenuItem.name = "HWGitHub";
				linksSubmenu.addItem(linkHWGitHubMenuItem);
				helpSubmenu.addSubmenu(linksSubmenu, "Links");
				sepMenuItem = new NativeMenuItem("", true);
				helpSubmenu.addItem(sepMenuItem);

			var aboutMenuItem:NativeMenuItem = new NativeMenuItem("About...");
				aboutMenuItem.name = "about";
				helpSubmenu.addItem(aboutMenuItem);
			windowMenu.addSubmenu(helpSubmenu, "Help");


			windowMenu.addEventListener(Event.SELECT, windowMenuSelect_h);
			function windowMenuSelect_h(e:Event):void {
				if (/^openDir$/.test(e.target.name)) {
					//openDir();
				} else if (/^saveCfg$/.test(e.target.name)) {
					//saveCfg();
				} else if (/^refresh$/.test(e.target.name)) {
					//refresh();
				} else if (/^exit$/.test(e.target.name)) {
					//exit();
				}
			}


			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.nativeWindow.menu = windowMenu;
			stage.nativeWindow.maximize();

			openDefault();
		}




		public var fileStream:FileStream = new FileStream();

		public var settingsFile:File = new File(File.applicationDirectory.nativePath + "/settings.xml");
		public var settings:XML = new XML(<settings/>);

		public var themeDir:File;
		public function openDefault():void {
			fileStream.open(settingsFile, FileMode.READ);
			settings = new XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close();


			themeDir = new File(settings.themeDir);

			loadImage(String(themeDir.nativePath + "\\" + settings.terrain.landTex), "landTex");
			loadImage(String(themeDir.nativePath + "\\" + settings.terrain.landBackTex), "landBackTex");
			loadImage(String(themeDir.nativePath + "\\" + settings.terrain.border[0]), "border");
			loadImage(String(themeDir.nativePath + "\\" + settings.terrain.girder), "girder");
			loadImage(String(themeDir.nativePath + "\\" + settings.terrain.amGirder), "amGirder");

			loadImage(String(themeDir.nativePath + "\\" + settings.objects.object[0]), "object");
			loadImage(String(themeDir.nativePath + "\\" + settings.objects.spray[0]), "spray");
			loadImage(String(themeDir.nativePath + "\\" + settings.objects.flake), "flake");

			loadImage(String(themeDir.nativePath + "\\" + settings.sky.sky[0]), "sky");
			loadImage(String(themeDir.nativePath + "\\" + settings.sky.horizont), "horizont");
			loadImage(String(themeDir.nativePath + "\\" + settings.sky.clouds[0]), "clouds");

			loadImage(String(themeDir.nativePath + "\\" + settings.water.blueWater), "blueWater");

			loadImage(String(themeDir.nativePath + "\\" + settings.particles.chunk), "chunk");
		}
		public function loadImage(url:String, target:String):void {
			loadImagesNum++;
			var request:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();
				loader.name = target;
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadImage_h);
				loader.load(request);
		}
		public var loadImagesNum:uint = 0;
		public function loadImage_h(e:Event):void {
			//fucking technique
			this[e.target.loader.name] = e.target.content;
			loadImagesNum--;
			if (loadImagesNum == 0) {
				drawImages();
			}
		}



		public var map:Sprite = new Sprite();

		public var landTex:Bitmap;
		public var landBackTex:Bitmap;
		public var border:Bitmap;
		public var girder:Bitmap;
		public var amGirder:Bitmap;

		public var object:Bitmap;
		public var spray:Bitmap;
		public var flake:Bitmap;
		public var flake_a:Array = [];

		public var sky:Bitmap;
		public var horizont:Bitmap;
		public var clouds:Bitmap;

		public var blueWater:Bitmap;

		public var chunk:Bitmap;
		public function drawImages():void {
			stage.addChild(map);


			var skyColor:uint = parseColor(settings.sky.sky[1]);
			stage.color = skyColor;

			var skyFill:Sprite = new Sprite();
				skyFill.graphics.beginBitmapFill(sky.bitmapData);
				skyFill.graphics.drawRect(0, 0, stage.stageWidth, sky.height);
				skyFill.graphics.endFill();
				skyFill.y = stage.stageHeight - 100 - sky.height;
				skyFill.cacheAsBitmap = true;
			map.addChild(skyFill);

			var horizontFill:Sprite = new Sprite();
				horizontFill.graphics.beginBitmapFill(horizont.bitmapData);
				horizontFill.graphics.drawRect(0, 0, stage.stageWidth, horizont.height);
				horizontFill.graphics.endFill();
				horizontFill.y = stage.stageHeight - 100 - horizont.height;
				horizontFill.cacheAsBitmap = true;
			map.addChild(horizontFill);


			for (var cloudsNum:uint = 0; cloudsNum < settings.sky.clouds[1]; cloudsNum++) {
				var cloudMask:Sprite = new Sprite();
					cloudMask.graphics.beginFill(0x0);
					cloudMask.graphics.drawRect(0, 0, 256, 128);
					cloudMask.graphics.endFill();
				var cloudFrame:Bitmap = new Bitmap(clouds.bitmapData, PixelSnapping.AUTO, true);
					cloudFrame.y = 0 - 128 * randomInt(0, clouds.height / 128 - 1);
				var cloud:Sprite = new Sprite();
					cloud.addChild(cloudMask);
					cloud.mask = cloudMask;
					cloud.addChild(cloudFrame);
					cloud.y = 100;
					cloud.scaleX = cloud.scaleY = 0.33 + 0.1 * randomInt(0, 5);
					cloud.cacheAsBitmap = true;
				map.addChild(cloud);
				var tween:TweenMax = new TweenMax(cloud, randomInt(25, 30), {x:stage.stageWidth - 256});
					tween.currentProgress = Math.random();
					tween.repeat =-1;
					tween.yoyo = true;
			}



			var landTex_r:Rectangle = new Rectangle((stage.stageWidth - stage.stageWidth / 1.75) / 2,
													stage.stageHeight - 125 - (stage.stageHeight - 350),
													stage.stageWidth / 1.75,
													stage.stageHeight - 375);
			var girderUnit:Sprite = new Sprite();
				girderUnit.addChild(girder);
				girderUnit.x = landTex_r.x - girder.width;
				girderUnit.y = landTex_r.y + landTex_r.height / 2 - girder.height / 2;
				girderUnit.cacheAsBitmap = true;
			map.addChild(girderUnit);

			var amGirderMask:Sprite = new Sprite();
				amGirderMask.graphics.beginFill(0x0);
				amGirderMask.graphics.drawRect(0, 0, 160, 160);
				amGirderMask.graphics.endFill();
			amGirder.x =-160;
			amGirder.y =-160;
			var amGirderUnit:Sprite = new Sprite();
				amGirderUnit.addChild(amGirderMask);
				amGirderUnit.mask = amGirderMask;
				amGirderUnit.addChild(amGirder);
				amGirderUnit.x = landTex_r.x + landTex_r.width + 50;
				amGirderUnit.y = landTex_r.y + landTex_r.height / 2 - 160 / 2;
				amGirderUnit.cacheAsBitmap = true;
			map.addChild(amGirderUnit);


			var objectPar:Array = settings.objects.object[1].split(",");
			var buried_pt:Point = new Point(uint(objectPar[2]), uint(objectPar[3]));
			var visible_pt:Point = new Point(uint(objectPar[7]), uint(objectPar[8]));
			var buried_r:Rectangle = new Rectangle(uint(objectPar[2]), uint(objectPar[3]), uint(objectPar[4]), uint(objectPar[5]));
			var visible_r:Rectangle = new Rectangle(uint(objectPar[7]), uint(objectPar[8]), uint(objectPar[9]), uint(objectPar[10]));
			var random_pt:Point = new Point();
			//brute force
			while (!landTex_r.containsRect(buried_r) || landTex_r.intersects(visible_r)) {
				random_pt.x = Math.random() * stage.stageWidth;
				random_pt.y = Math.random() * stage.stageHeight;

				buried_r.x = random_pt.x + buried_pt.x;
				buried_r.y = random_pt.y + buried_pt.y;
				visible_r.x = random_pt.x + visible_pt.x;
				visible_r.y = random_pt.y + visible_pt.y;
			}
			var objectUnit:Sprite = new Sprite();
				objectUnit.addChild(object);
				objectUnit.scaleX = objectUnit.scaleY = 0.5;
				objectUnit.x = buried_r.x - buried_pt.x / 2;
				objectUnit.y = buried_r.y - buried_pt.y / 2;
				objectUnit.cacheAsBitmap = true;
			map.addChild(objectUnit);

			var landTexMatrix:Matrix = new Matrix();
				landTexMatrix.scale(0.5, 0.5);
			var landTexFill:Sprite = new Sprite();
				landTexFill.graphics.beginBitmapFill(landTex.bitmapData, landTexMatrix);
				landTexFill.graphics.drawRect(0, 0, landTex_r.width, landTex_r.height);
				landTexFill.graphics.endFill();
				landTexFill.x = landTex_r.x;
				landTexFill.y = landTex_r.y;
				landTexFill.cacheAsBitmap = true;
			map.addChild(landTexFill);



			var sprayPar:Array = settings.objects.spray[1].split(",");
			var spraySheet:Sprite = new Sprite();
			var sprayMask:Sprite = new Sprite();
				sprayMask.graphics.beginFill(0x0);
				sprayMask.graphics.drawRect(landTex_r.x, landTex_r.y, landTex_r.width, landTex_r.height);
				sprayMask.graphics.endFill();
			for (var sprayNum:uint = 0; sprayNum < uint(sprayPar[1]); sprayNum++) {
				var sprayUnit:Bitmap = new Bitmap(spray.bitmapData);
					sprayUnit.scaleX = sprayUnit.scaleY = 0.5;
					sprayUnit.x = landTex_r.x + Math.random() * landTex_r.width;
					sprayUnit.y = landTex_r.y + Math.random() * landTex_r.height;
				spraySheet.addChild(sprayUnit);
			}
				spraySheet.mask = sprayMask;
				spraySheet.cacheAsBitmap = true;
			map.addChild(spraySheet);



			var borderMatrix:Matrix = new Matrix();
				borderMatrix.translate(0, -16);
			var borderTopFill:Sprite = new Sprite();
				borderTopFill.graphics.beginBitmapFill(border.bitmapData);
				borderTopFill.graphics.drawRect(0, 0, landTex_r.width, 16);
				borderTopFill.graphics.endFill();
				borderTopFill.x = landTex_r.x;
				borderTopFill.y = landTex_r.y;
				borderTopFill.cacheAsBitmap = true;
			map.addChild(borderTopFill);
			var borderBottomFill:Sprite = new Sprite();
				borderBottomFill.graphics.beginBitmapFill(border.bitmapData, borderMatrix);
				borderBottomFill.graphics.drawRect(0, 0, landTex_r.width, 16);
				borderBottomFill.graphics.endFill();
				borderBottomFill.x = landTex_r.x;
				borderBottomFill.y = landTex_r.y + landTex_r.height - 16;
				borderBottomFill.cacheAsBitmap = true;
			map.addChild(borderBottomFill);

			var borderColor:uint = parseColor(settings.terrain.border[1]);
			var borderMask:Sprite = new Sprite();
				borderMask.graphics.beginFill(0x0);
				borderMask.graphics.drawCircle(stage.stageWidth / 2, landTex_r.y, 103);
				borderMask.graphics.drawCircle(stage.stageWidth / 2, landTex_r.y, 100);
				borderMask.graphics.endFill();
			var borderFill:Sprite = new Sprite();
				borderFill.graphics.beginFill(borderColor);
				borderFill.graphics.drawRect(0, 0, landTex_r.width, landTex_r.height);
				borderFill.graphics.endFill();
				borderFill.x = landTex_r.x;
				borderFill.y = landTex_r.y;
				borderFill.mask = borderMask;
				borderFill.cacheAsBitmap = true;
			map.addChild(borderFill);


			var landBackTexMask:Sprite = new Sprite();
				landBackTexMask.graphics.beginFill(0x0);
				landBackTexMask.graphics.drawCircle(stage.stageWidth / 2, landTex_r.y, 100);
				landBackTexMask.graphics.endFill();
			var landBackTexFill:Sprite = new Sprite();
				landBackTexFill.graphics.beginBitmapFill(landBackTex.bitmapData, landTexMatrix);
				landBackTexFill.graphics.drawRect(0, 0, landTex_r.width, landTex_r.height);
				landBackTexFill.graphics.endFill();
				landBackTexFill.x = landTex_r.x;
				landBackTexFill.y = landTex_r.y;
				landBackTexFill.mask = landBackTexMask;
				landBackTexFill.cacheAsBitmap = true;
			map.addChild(landBackTexFill);



			var waterTopColor:uint = parseColor(settings.water["water-top"]);
			var waterBottomColor:uint = parseColor(settings.water["water-bottom"]);
			var waterOpacity:uint = settings.water["water-opacity"];
			var matrix:Matrix = new Matrix();
				matrix.createGradientBox(stage.stageWidth, 100, Math.PI / 2);
			var waterGradientFillBG:Sprite = new Sprite();
				waterGradientFillBG.graphics.beginGradientFill(GradientType.LINEAR, [waterTopColor, waterBottomColor], [1, 1], [0, 255], matrix);
				waterGradientFillBG.graphics.drawRect(0, 0, stage.stageWidth, 100);
				waterGradientFillBG.graphics.endFill();
				waterGradientFillBG.y = stage.stageHeight - 100;
				waterGradientFillBG.cacheAsBitmap = true;
			map.addChild(waterGradientFillBG);


			var flakesPar_a:Array = settings.objects.flakes.split(",");
			var flakeDelay:uint = uint(flakesPar_a[2]);
			for (var flakesNum:uint = 0; flakesNum < uint(flakesPar_a[0]); flakesNum++) {
				var flakeMask:Sprite = new Sprite();
					flakeMask.graphics.beginFill(0x0);
					flakeMask.graphics.drawRect(0, 0, 64, 64);
					flakeMask.graphics.endFill();
				var flakeFrame:Bitmap = new Bitmap(flake.bitmapData);
					flakeFrame.x = 0 - 64 * randomInt(0, flake.width / 64 - 1);
					flakeFrame.y = 0 - 64 * randomInt(0, flake.height / 64 - 1);
					flake_a.push(flakeFrame);
				var flakeUnit:Sprite = new Sprite();
					flakeUnit.addChild(flakeMask);
					flakeUnit.mask = flakeMask;
					flakeUnit.addChild(flakeFrame);
					flakeUnit.rotation = Math.random() * 360;
					flakeUnit.x = Math.random() * stage.stageWidth;
					flakeUnit.y = 100;
					flakeUnit.cacheAsBitmap = true;
				map.addChild(flakeUnit);
				var tweenDuration:Number = stage.stageHeight / (uint(flakesPar_a[4]) / 3);
					tween = new TweenMax(flakeUnit, tweenDuration, {x:flakeUnit.x - stage.stageWidth / 3, y:stage.stageHeight, rotation:tweenDuration * uint(flakesPar_a[3])});
					tween.currentProgress = Math.random();
					tween.repeat =-1;
			}
			if (flakeDelay != 0) {
				var flakeTimer:Timer = new Timer(flakeDelay);
					flakeTimer.addEventListener(TimerEvent.TIMER, flakeTimer_h);
					flakeTimer.start();
			}


			var blueWaterFill:Sprite = new Sprite();
				blueWaterFill.graphics.beginBitmapFill(blueWater.bitmapData);
				blueWaterFill.graphics.drawRect(0, 0, stage.stageWidth, blueWater.height);
				blueWaterFill.graphics.endFill();
				blueWaterFill.y = stage.stageHeight - 100 - blueWater.height / 1.5;
				blueWaterFill.cacheAsBitmap = true;
			map.addChild(blueWaterFill);


			var waterGradientFill:Sprite = new Sprite();
				waterGradientFill.graphics.beginGradientFill(GradientType.LINEAR, [waterTopColor, waterBottomColor], [waterOpacity / 255, waterOpacity / 255], [0, 255], matrix);
				waterGradientFill.graphics.drawRect(0, 0, stage.stageWidth, 100);
				waterGradientFill.graphics.endFill();
				waterGradientFill.y = stage.stageHeight - 100;
				waterGradientFill.cacheAsBitmap = true;
			map.addChild(waterGradientFill);





			//trace(stage.stageHeight,sky.height)
		}
		public function flakeTimer_h(e:TimerEvent):void {
			var flakeFrame:Bitmap;
			for (var flakeNum:uint = 0; flakeNum < flake_a.length; flakeNum++) {
				flakeFrame = flake_a[flakeNum];
				if (flakeFrame.y > -flake.height + 64) {
					flakeFrame.y -= 64;
				} else {
					if (flakeFrame.x > -flake.width + 64) {
						flakeFrame.x -= 64;
						flakeFrame.y = 0;
					} else {
						flakeFrame.x = 0;
						flakeFrame.y = 0;
					}
				}
			}
		}
		public function parseColor(color_s:String):uint {
			var color_a:Array = color_s.split(",");
			var color:uint = Color.rgb(uint(color_a[0]), uint(color_a[1]), uint(color_a[2]));

			return color;
		}
		public function randomInt(min:int, max:int):int {
			var interval_a:Array = [];
			var randoms_a:Array = [];
			for (var i:int = min; i <= max; i++) {
				interval_a.push(i);
				randoms_a.push(Math.random());
			}

			var order_a:Array = randoms_a.sort(Array.NUMERIC | Array.RETURNINDEXEDARRAY);

			return interval_a[order_a[0]];
		}


	}
}
display.setStatusBar(display.HiddenStatusBar)

local physics = require("physics");
physics.start();
physics.setGravity(0, 0);

local bgMusic = audio.loadStream("sounds/ZombieBreakTheme.mp3");
local zombieKill = audio.loadSound("sounds/ow.mp3");

-- "Constants"
local _W = display.contentWidth / 2;
local _H = display.contentHeight / 2;

-- Variables
local zombies = display.newGroup();
local zombieWidth = 50;
local zombieHeight = 50;
local row;
local column;
local score = 0;
local currentLevel;
local velocityX = 3;
local velocityY = -3;
local gameEvent = "";

-- Menu Screen
local titleScreenGroup;
local titleScreen;
local playBtn;
 
-- Game Screen
local background;
local player;
local zombie;
local bullet;
 
-- Score/Level Text
local zombieKillText;
local zombieKillNum;
local levelText;
local levelNum;
 
-- textBoxGroup
local textBoxGroup;
local textBox;
local conditionDisplay;
local messageText;



-- -- Physics Engine
-- local physics = require("physics");
-- physics.start();
-- physics.setGravity(0, 0);

function main()
	showTitleScreen();
end

function loadGame( event )
	if event.target.name == "playbutton" then
		audio.play(bgMusic, {loops == -1});
		audio.setVolume(0.1);
		transition.to(titleScreenGroup,{time = 0, alpha=0, onComplete = initializeGameScreen});
		playBtn:removeEventListener("tap", loadGame);
	end
end

function gameLevel1()
	currentLevel = 1;
 
	-- Place the zombies on the top layer
	zombies:toFront();
 
	-- Number of zombies on level 1
	local numOfRows = 2;
	local numOfColumns = 2;

	-- Zombie position on screen
	local zombiePlacement = {x = (_W) - (zombieWidth * numOfColumns ) / 2  + 20, y = 70};
	for row = 0, numOfRows - 1 do
		for column = 0, numOfColumns - 1 do
			local zombie = display.newImage("images/zombie.png");
			zombie.name = "zombie";
			zombie.x = zombiePlacement.x + (column * zombieWidth);
			zombie.y = zombiePlacement.y + (row * zombieHeight);

			-- Add physics properties to zombies
			physics.addBody(zombie, "static", {density = 1, friction = 0, bounce = 0});
			zombies.insert(zombies, zombie);
		end
	end

end
function initializeGameScreen( ... )
	player = display.newImage("images/player.png");
	player.x = _W;
	player.y = _H + 140;
	player.name = "player";

		-- Place bullet on screen
	bullet = display.newImage("images/bullet.png");
	bullet.x = _W;
	bullet.y = player.y - 30;
	bullet.name = "bullet";

	-- Score text
	zombieKillText = display.newText("Zombies Killed: ", 25, 2, "Arial", 14);
	zombieKillText:setTextColor(255, 255, 255, 255);
	zombieKillNum = display.newText("0", 150, 2, "Arial", 14);
	zombieKillNum:setTextColor(255, 255, 255, 255);

	levelText = display.newText("City:", 360, 2, "Arial", 14);
	levelText:setTextColor(255, 255, 255, 255);
	levelNum = display.newText("安徽工业大学", 400, 2, "Arial", 14);
	levelNum:setTextColor(255, 255, 255, 255);

	changeLevel1();


end

function movePlayer( event )
	-- TODO
	if event.phase == "began" then
		moveX = event.x - player.x;
		elseif event.phase == "moved" then
			player.x = event.x - moveX;
	end

	if((player.x - player.width * 0.5) < 0) then
		player.x = player.width * 0.5;
	elseif((player.x + player.width * 0.5) > display.contentWidth) then
		player.x = display.contentWidth - player.width * 0.5;
	end
end
function changeLevel1( ... )
	-- body
	bg1 = display.newImage("images/atl.png", 0, 0, true );
	bg1.x = _W;
	bg1.y = _H;
	bg1:toBack();

	player:addEventListener("tap", startGame)

	gameLevel1();

end
function showTitleScreen()
	titleScreenGroup = display.newGroup();
	titleScreen = display.newImage("images/titleScreen.png", 0, 0, true);
	titleScreen.x = _W;
	titleScreen.y = _H;

	playBtn = display.newImage("images/playButton.png");
	playBtn.x = _W;
	playBtn.y = _H + 50;
	playBtn.name = "playbutton";

	-- Insert background and button into group
	titleScreenGroup:insert(titleScreen);
	titleScreenGroup:insert(playBtn);

	playBtn:addEventListener("tap", loadGame);
end

function startGame()
	physics.addBody(player, "static", {density = 1, friction = 0, bounce = 0});
	physics.addBody(bullet,"dynamic", {density = 1, friction = 0, bounce = 0});
	player:removeEventListener("tap", startGame);
	gameListeners("add");

end

function updatebullet(  )
	bullet.x = bullet.x + velocityX;
	bullet.y = bullet.y + velocityY;

	if bullet.x < 0 or bullet.x + bullet.width > display.contentWidth then
		velocityX = -velocityX;
	end
	if bullet.y < 0 then
		velocityY = - velocityY;
	end

	if bullet.y + bullet.height > player.y + player.height then
		textBoxScreen("男哥的大脑已经阵亡", "敢射准点?") gameEvent = "lose";
	end
end

-- Zombies are exterminated, remove them from screen
function zombieDestroyed(event)
 
	-- Where did the bullet hit the zombie?
	if event.other.name == "zombie" and bullet.x + bullet.width * 0.5 < event.other.x + event.other.width * 0.5 then
		velocityX = -velocityX;
	elseif event.other.name == "zombie" and bullet.x + bullet.width * 0.5 >= event.other.x + event.other.width * 0.5 then
		velocityX = velocityX;
	end
 
	-- Ricochet the bullet off the zombie and remove him from the screen
	if event.other.name == "zombie" then
		-- Bounce the bullet
		velocityY = velocityY * -1;
		-- Zombie says "ow" when hit by a bullet
		audio.play(zombieKill);
		-- Remove zombie instance
		event.other:removeSelf();
		event.other = nil;
		-- One less zombie
		zombies.numChildren = zombies.numChildren - 1;
 
		-- Score
		score = score + 1;
		zombieKillNum.text = score;
		zombieKillNum:setReferencePoint(display.CenterLeftReferencePoint);
		zombieKillNum.x = 150;
	end
 
	-- Check if all zombies are destroyed
	if zombies.numChildren < 0 then
		textBoxScreen("City: Zombie Free", "Next City");
		gameEvent = "win";
	end
end
function gameListeners(event)
	if event == "add" then
		Runtime:addEventListener("enterFrame", updatebullet);
		-- Bookmark A: You'll be adding some code here later
		player:addEventListener("collision", bounce);

		player:addEventListener("touch", movePlayer);
		bullet:addEventListener("collision", zombieDestroyed);


	-- Remove listeners when not needed to free up memory
	elseif event == "remove" then
		Runtime:removeEventListener("enterFrame", updatebullet);
		-- Bookmark B: You'll be adding some code here later too
		player:removeEventListener("touch", movePlayer);
		player:removeEventListener("collision", bounce);
		bullet:removeEventListener("collision", zombieDestroyed);



	end
end

-- Level 2 zombies
function gameLevel2()
	currentLevel = 2;
	bg1.isVisible = false;
 
	-- This code is the same to gameLevel1(), but you can change the number of zombies on screen.
	zombies:toFront();
	local numOfRows = 2;
	local numOfColumns = 8;
 
	-- Zombie position on screen
	local zombiePlacement = {x = (_W) - (zombieWidth * numOfColumns ) / 2  + 20, y = 100};
 
	-- Create zombies based on the number of columns and rows we declared
	for row = 0, numOfRows - 1 do
		for column = 0, numOfColumns - 1 do
			local zombie = display.newImage("images/zombie.png");
			zombie.name = "zombie";
			zombie.x = zombiePlacement.x + (column * zombieWidth);
			zombie.y = zombiePlacement.y + (row * zombieHeight);
 
			-- Add physics properties to zombies
			physics.addBody(zombie, "static", {density = 1, friction = 0, bounce = 0});
			zombies.insert(zombies, zombie);
		end
	end

end

function cleanupLevel()
	-- Clear old zombies 
	zombies:removeSelf();
	zombies.numChildren = 0;
	zombies = display.newGroup();
 
	-- Remove text Box
	textBox:removeEventListener("tap", restart);
	textBoxGroup:removeSelf();
	textBoxGroup = nil;
 
	-- Reset bullet and player position 
	bullet.x = _W;
	bullet.y = player.y - 30;
	player.x = _W;
 
	score = 0;
	zombieKillNum.text = "0";
end


function bounce(  )
	velocityY = -3
	if((bullet.x + bullet.width * 0.5) < player.x) then
		velocityX = -velocityX;
	elseif((bullet.x + bullet.width * 0.5) >= player.x) then
		velocityX = velocityX;
	end
end

-- New York City (Level 2)
function changeLevel2()
 
	-- Display background image and move it to the back
	bg2 = display.newImage("images/nyc.png", 0, 0, true);
	bg2.x = _W;
	bg2.y = _H;
	bg2:toBack();
 
	-- Reset zombies 
	gameLevel2();
 
	-- Start
	player:addEventListener("tap", startGame)
end

function textBoxScreen(title, message)
	gameListeners("remove");
 
	-- Display text box with win or lose message
	textBox = display.newImage("images/textBox.png");
	textBox.x = 240;
	textBox.y = 160;
 
	-- Win or Lose Text
	conditionDisplay = display.newText(title, 0, 0, "Arial", 38);
	conditionDisplay:setTextColor(255,255,255,255);
	conditionDisplay.xScale = 0.5;
	conditionDisplay.yScale = 0.5;
	conditionDisplay:setReferencePoint(display.CenterReferencePoint);
	conditionDisplay.x = display.contentCenterX;
	conditionDisplay.y = display.contentCenterY - 15;
 
	--Try Again or Congrats Text
	messageText = display.newText(message, 0, 0, "Arial", 24);
	messageText:setTextColor(255,255,255,255);
	messageText.xScale = 0.5;
	messageText.yScale = 0.5;
	messageText:setReferencePoint(display.CenterReferencePoint);
	messageText.x = display.contentCenterX;
	messageText.y = display.contentCenterY + 15;
 
	-- Add all elements into a new group
	textBoxGroup = display.newGroup();
	textBoxGroup:insert(textBox);
	textBoxGroup:insert(conditionDisplay);
	textBoxGroup:insert(messageText);
 
	-- Make text box interactive
	textBox:addEventListener("tap", restart);
end

-- See if the player won or lost the level
function restart()
	-- If the player wins level 1, then go to level 2
	if gameEvent == "win" and currentLevel == 1 then
		currentLevel = currentLevel + 1;
		cleanupLevel();
		changeLevel2();
		levelNum.text = tostring("NYC");
 
	-- If the player wins level 2, tell them they won the game
	elseif gameEvent == "win" and currentLevel == 2 then	
		textBoxScreen("  You Survived!", "  Congratulations!");
		gameEvent = "completed";
 
	-- If the player loses level 1, then make them retry level 1 and reset score to 0
	elseif gameEvent == "lose" and currentLevel == 1 then
		cleanupLevel();
		changeLevel1();
 
	-- If the player loses level 2, then make them retry level 2 and reset score to 0
	elseif gameEvent == "lose" and currentLevel == 2 then
		cleanupLevel();
		changeLevel2();
 
	-- If the game has been completed, remove the listener of the text box to free up memory
	elseif gameEvent == "completed" then
		textBox:removeEventListener("tap", restart);
	end
end
main();
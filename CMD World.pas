program CMDWorld;
 
uses crt;

type
    Entity = record
        x: integer;
        y: integer;
        graphic: char;
        color: integer;
        collidable: boolean;
        collectable: boolean;
        slippable: boolean;
    end;

var
    // Bricks
    bricks: array [1..2000] of Entity;
    bricksCount: integer;

    // Money items
    moneyItems: array [1..20] of Entity;
    moneyItemsCount: integer;

    // Player
    player: Entity;

    // Key
    key: Entity;
    hasKey: boolean;

    // Door
    door: Entity;

    currentLevel: integer;

    // Jump
    isJumping: boolean;
    jumpHeight: byte;
    jumpsCount: byte;

    levelsColors: array [1..10] of integer;

function BooleanToInt(bool : boolean): integer;
begin
    if (bool = true) then
        BooleanToInt := 1
    else
        BooleanToInt := 0;
end;

function IntToBoolean(int : integer): boolean;
begin
    if (int = 1) then
        IntToBoolean := true
    else
        IntToBoolean := false;
end;

procedure AddBrick(posX: integer; posY: integer);
begin
    bricksCount := bricksCount + 1;

    with bricks[bricksCount] do
    begin
        x := posX;
        y := posY;
        graphic := #178;
        collidable := true;
        collectable := false;
        color := 4;
        slippable := false;
    end;
end;

procedure AddMoneyItem(posX: integer; posY: integer);
begin
    moneyItemsCount := moneyItemsCount + 1;
    
    with moneyItems[moneyItemsCount] do
    begin
        x := posX;
        y := posY;
        graphic := '$';
        collidable := false;
        collectable := true;
        color := yellow;
        slippable := false;
    end;
end;

procedure SetupPlayer(posX: integer; posY: integer);
begin
    with player do
    begin
        x := posX;
        y := posY;
        graphic := #244;
        color := 8;
        collidable := true;
        collectable := false;
        slippable := false;
    end;
end;

procedure SetupKey(posX: integer; posY: integer);
begin
    with key do
    begin
        x := posX;
        y := posY;
        graphic := #158;
        color := 14;
        collidable := false;
        collectable := true;
        slippable := false;
    end;
end;

procedure SetupDoor(posX: integer; posY: integer);
begin
    with door do
    begin
        x := posX;
        y := posY;
        graphic := #195;
        color := 15;
        collidable := true;
        collectable := false;
        slippable := false;
    end;
end;

procedure DrawBricks;
var
    i: integer;
begin
    for i := 0 to bricksCount do
    begin
        with bricks[i] do
        begin
            textcolor(color);
            gotoxy(x, y);
            write(graphic);
        end;
    end;
end;

procedure DrawMoney;
var
    i: integer;
begin
    for i := 0 to moneyItemsCount do
    begin
        with moneyItems[i] do
        begin
            textcolor(color);
            gotoxy(x, y);
            write(graphic);
        end;
    end;
end;

procedure DrawPlayer;
begin
    gotoxy(player.x, player.y);
    textcolor(red);
    write(player.graphic);
end;

procedure DrawKey;
begin
    if (hasKey = false) then
    begin
        gotoxy(key.x, key.y);
        textcolor(white);
        write(key.graphic);
    end;
end;

procedure DrawDoor;
begin
    gotoxy(door.x, door.y);
    write(door.graphic);
end;

function HasGotTheKey : boolean;
begin
    if (key.collectable = true) and (player.x = key.x) and (player.y = key.y) then
        HasGotTheKey := true
    else
        HasGotTheKey := false;
end;

function HasReachedTheDoor : boolean;
begin
    if (door.collidable = false) and (player.x = door.x) and (player.y = door.y) then
        HasReachedTheDoor := true
    else
        HasReachedTheDoor := false;
end;

function HasDied : boolean;
begin
    if (player.y > 25) then
        HasDied := true
    else
        HasDied := false;
end;

function DetectPlayerOnBrickCollision: boolean;
var
    i: integer;
begin
    DetectPlayerOnBrickCollision := false;
    
    for i := 0 to bricksCount do
    begin
        with bricks[i] do
        begin
            if (collidable = true) and (player.x = x) and (player.y = y) then
                DetectPlayerOnBrickCollision := true;
        end;
    end;
end;

function DetectPlayerOnDoorCollision: boolean;
begin
    DetectPlayerOnDoorCollision := false;
    
    with door do
    begin
        if (collidable = true) and (player.x = x) and (player.y = y) then
            DetectPlayerOnDoorCollision := true;
    end;
end;

function IsPlayerOnTheGround: boolean;
var
    i: integer;
begin
    IsPlayerOnTheGround := false;

    for i := 0 to bricksCount do
    begin
        with bricks[i] do
        begin
            if (collidable = true) and (player.x = x) and
                (player.y = y - 1) then
                IsPlayerOnTheGround := true;
        end;
    end;
end;

function IsPlayerUnderTheGround: boolean;
var
    i: integer;
begin
    IsPlayerUnderTheGround := false;

    for i := 0 to bricksCount do
    begin
        with bricks[i] do
        begin
            if (collidable = true) and (player.x = x) and
                (player.y = y + 1) then
                IsPlayerUnderTheGround := true;
        end;
    end;
end;

procedure ErasePlayer;
begin
    gotoxy(player.x, player.y);
    write(#255);
end;

procedure ApplyGravity();
begin
    if (IsPlayerOnTheGround() = false) and (isJumping = false) then
    begin
        ErasePlayer;
        player.y := player.y + 1;
        delay(30);
    end;
end;

procedure MoveLeft;
begin
    ErasePlayer;
    player.x := player.x - 1;
    if (DetectPlayerOnBrickCollision() = true) or
       (player.x <= 0) or
       (DetectPlayerOnDoorCollision() = true) then
    begin
        player.x := player.x + 1;
        jumpsCount := 0;
    end;
end;

procedure MoveRight;
begin
    ErasePlayer;
    player.x := player.x + 1;
    if (DetectPlayerOnBrickCollision() = true) or
       (player.x > 80) or
       (DetectPlayerOnDoorCollision() = true) then
    begin
        player.x := player.x - 1;
        jumpsCount := 0;
    end;
end;

function IsPlayerInsideTheGround: boolean;
var
    i: integer;
begin
    IsPlayerInsideTheGround := false;

    for i := 0 to bricksCount do
    begin
        with bricks[i] do
        begin
            if (collidable = true) and (player.x = x) and (player.y = y) then
                IsPlayerInsideTheGround := true;
        end;
    end;
end;

procedure Jump;
begin
    jumpHeight := jumpHeight + 1;
    isJumping := true;
    ErasePlayer;
    player.y := player.y - 1;
    delay(50);
    if (jumpHeight = 6) then
    begin

        jumpHeight := 0;
        isJumping := false;
    end;
    if (IsPlayerInsideTheGround = true) then
    begin
        jumpHeight := 0;
        isJumping := false;
        player.y := player.y + 1;
    end;
    if (IsPlayerUnderTheGround = true) then
    begin
        jumpHeight := 0;
        isJumping := false;
    end;
end;
    
procedure Draw;
begin
    DrawBricks;
    DrawDoor;
    DrawKey;
    DrawMoney;
    gotoxy(1,1);
end;

procedure UnloadCurrentLevel;
begin
    hasKey := false;
    door.collidable := true;
    bricksCount := 0;
    moneyItemsCount := 0;
    clrscr;
end;

procedure LoadLevel(levelNumber: integer);
var
    i: integer;
    lineNumber: integer;
    lineText: string;
    fileName : string;
    levelFile: text;
begin
    UnloadCurrentLevel;

    str(levelNumber, lineText);
    fileName := Concat('levels\level', lineText, '.map');
    assign(levelFile, fileName);

    reset(levelFile);
    lineNumber := 1;
    while not Eof(levelFile) do
    begin
        Readln(levelFile, lineText);

        for i := 1 to 80 do
        begin
            case lineText[i] of
                'x':
                    AddBrick(i, lineNumber);
                '$':
                    AddMoneyItem(i, lineNumber);
                'p':
                    SetupPlayer(i, lineNumber);
                'd':
                    SetupDoor(i, lineNumber);
                'k':
                    SetupKey(i, lineNumber);
            end;
        end;

        lineNumber := lineNumber + 1;
    end;

    textbackground(levelsColors[currentLevel]);
    clrscr;

    close(levelFile);
end;

procedure SaveState;
var
    i: Integer;
    stateFile: file of integer;
begin
    assign(stateFile, 'states\state.sav');
    rewrite(stateFile);

    write(stateFile, currentLevel);
    write(stateFile, player.x);
    write(stateFile, player.y);

    i := BooleanToInt(hasKey);
    write(stateFile, i);

    close(stateFile);
end;

procedure LoadState;
var
    stateFile: file of integer;
    i: Integer;
begin
    assign(stateFile, 'states\state.sav');
    reset(stateFile);

    read(stateFile, currentLevel);

    UnloadCurrentLevel;
    LoadLevel(currentLevel);

    read(stateFile, player.x);
    read(stateFile, player.y);
    read(stateFile, i);

    hasKey := IntToBoolean(i);
    door.collidable := not(hasKey);

    Draw;

    close(stateFile);
end;

procedure KeyboardInput;
begin
    if (keypressed) then
        case readkey of
            #75:
                MoveLeft;
            #77:
                MoveRight;
            #27:
                Halt(0);
            #32:
                if (jumpsCount < 2) then
                begin
                    isJumping := true;
                    jumpsCount := jumpsCount + 1;
                end;
            #97:
                SaveState;
            #100:
            begin
                ErasePlayer;
                LoadState;
            end;
        end;
end;

procedure ShowTitleMenu();
var
    i: integer;
    lineNumber: integer;
    lineText: string;
    levelFile: text;
begin
    UnloadCurrentLevel;

    assign(levelFile, 'levels\title_menu.map');

    reset(levelFile);
    lineNumber := 1;
    while not Eof(levelFile) do
    begin
        Readln(levelFile, lineText);
        
        for i := 1 to 80 do
        begin
            case lineText[i] of
                'x':
                    AddBrick(i, lineNumber);
                '$':
                    AddMoneyItem(i, lineNumber);
                'p':
                    SetupPlayer(i, lineNumber);
                'd':
                    SetupDoor(i, lineNumber);
                'k':
                    SetupKey(i, lineNumber);
            end;
        end;

        lineNumber := lineNumber + 1;
    end;

    close(levelFile);

    textbackground(green);
    clrscr;
    Draw;
	gotoxy(34, 21);
    write('Press any key');
    readkey;
    
    LoadLevel(1);
end;

procedure Initialize;
begin
    levelsColors[1] := 11;
    levelsColors[2] := 7;
    levelsColors[3] := 10;
    levelsColors[4] := 14;
    levelsColors[5] := 3;
    levelsColors[6] := 1;
    levelsColors[7] := 15;
    levelsColors[8] := 0;
    levelsColors[9] := 0;
    levelsColors[10] := 0;

    currentLevel := 1;
    ShowTitleMenu();
end;

procedure ShowMessage(bgColor: integer; txtColor: integer; message: string);
begin
     textBackground(bgColor);
     clrscr;
     gotoxy(round(40 - length(message) / 2), 13);
     textcolor(txtColor);
     write(message);
     readkey;
end;

procedure Update;
begin
    ApplyGravity();

    if (HasGotTheKey = true) then
    begin
        hasKey := true;
        door.collidable := false;
    end;

    if (HasReachedTheDoor = true) then
    begin
        if (currentLevel = 10) then
        begin
            ShowMessage(blue, white, 'CONGRATULATIONS, YOU ARE A TRUE GOD!!!');
            currentLevel := 1;
            ShowTitleMenu();
        end
        else
        begin
            currentLevel := currentLevel + 1;
            ShowMessage(green, white, 'LEVEL COMPLETED!');
            LoadLevel(currentLevel);
        Draw();
        end;
    end;

    if (HasDied = true) then
    begin
        ShowMessage(red, white, 'YOU HAVE FAILED!');
        LoadLevel(currentLevel);
        Draw();
    end;

    if (isJumping = true) then
        Jump;
    
    if (IsPlayerOnTheGround = true) then
        jumpsCount := 0;

    DrawPlayer;
    KeyboardInput;
    delay(25);
end;

 // Main Program
 begin
    Initialize;
    Draw;
    repeat
        Update;
    until false = true;
end.

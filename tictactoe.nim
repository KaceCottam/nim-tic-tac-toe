import options
import sequtils
import strutils

type Player = enum X, O
proc `$`(p: Player): string =
    if p == Player.X:
        return "X"
    else:
        return "O"

proc `not`(p: Player): Player =
    if p == Player.X:
        return Player.O
    else:
        return Player.X

type Space = Option[Player]
proc show(s: Space, idx: int): string =
    if s.isNone:
        return $idx
    else:
        return $s.get()

proc `$`(s: Space): string =
    if s.isNone:
        return " "
    else:
        return $s.get()


type Board = seq[Space]

proc newBoard(): Board = repeat(none(Player), 9)

proc `$`(b: Board): string =
    var idx = 0
    proc nextIdx(): int =
        idx += 1
        idx

    proc reverse(s: string): string =
        var res: string
        for i in s.rsplit(""):
            res &= i
        return res

    b.mapIt(it.show(nextIdx())).join("|").reverse().insertSep('_',6)
        .replace("_", "\n-+-+-\n").reverse().replace("|\n","\n") & "\n"

proc validIdx(b: Board, idx: int): bool =
    return b[idx].isNone

proc placeMark(b: Board, p: Player, idx: int): Board =
    var newBoard = b
    newBoard[idx] = some(p)
    return newBoard

iterator rotatedBoard(b: Board): tuple[a: int, b: Space] =
    var idx = 0
    for k, _ in b:
        let
            x = idx mod 3
            y = idx div 3
        yield (idx, b[(x*3) + y])

proc checkWin(b: Board, p: Player): bool =
    # horizontal
    var count = [0,0,0]
    for k, v in b:
        if v.isNone: continue
        let valid = (v.get == p)
        count[k mod 3] += valid.int

    for i in count:
        if i == 3:
            return true

    # vertical
    count = [0,0,0]
    for k, v in rotatedBoard(b):
        if v.isNone: continue
        let valid = (v.get == p)
        count[k mod 3] += valid.int

    for i in count:
        if i == 3:
            return true

    # diagonal top left to bottom right
    var valid = true
    for i in [0, 4, 8]:
        if b[i].get(not p) != p:
            valid = false
    if valid: return valid
    
    # diagonal bottom left to top right
    valid = true
    for i in [6, 4, 2]:
        if b[i].get(not p) != p:
            valid = false
    return valid

proc declareWinner(p: Player): void = echo "Player ", $p, " wins!"

proc gameLoop(b: Board, p: Player): void =
    echo $b
    echo "Player ", $p, ", please choose a valid index: "
    let idx = readLine(stdin).parseInt()
    if b.validIdx(idx - 1):
        let newBoard = b.placeMark(p, idx - 1)
        if newBoard.checkWin(p):
            declareWinner(p)
        else:
            gameLoop(newBoard, not p)
    else:
        gameLoop(b, p)

proc startGame(): void = 
    echo "Welcome to Tic-Tac-Toe!"
    gameLoop(newBoard(), Player.X)

startGame()

# TODO look for draws
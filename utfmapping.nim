import unicode
import termstyle

var fingerTable: seq[tuple[u16pos, offset: int]]

var x = "heållo☀☀wor𐐀𐐀☀ld heållo☀wor𐐀ld heållo☀wor𐐀ld"

var pos = 0
for rune in x.runes:
  echo pos
  echo rune.int32
  case rune.int32:
    of 0x0000..0x007F:
      # One UTF-16 unit, one UTF-8 unit
      pos += 1
    of 0x0080..0x07FF:
      # One UTF-16 unit, two UTF-8 units
      fingerTable.add (u16pos: pos, offset: 1)
      pos += 1
    of 0x0800..0xFFFF:
      # One UTF-16 unit, three UTF-8 units
      fingerTable.add (u16pos: pos, offset: 2)
      pos += 1
    of 0x10000..0x10FFFF:
      # Two UTF-16 units, four UTF-8 units
      fingerTable.add (u16pos: pos, offset: 2)
      pos += 2
    else: discard

echo fingerTable

let utf16pos = 5
var corrected = utf16pos
for finger in fingerTable:
  if finger.u16pos < utf16pos:
    corrected += finger.offset
  else:
    break

for y in x:
  if corrected == 0:
    echo "-"
  if ord(y) > 125:
    echo ord(y).red
  else:
    echo ord(y)
  corrected -= 1

echo "utf16\tchar\tutf8\tchar\tchk"
pos = 0
for c in x.runes:
  stdout.write pos
  stdout.write "\t"
  stdout.write c
  stdout.write "\t"
  var corrected = pos
  for finger in fingerTable:
    if finger.u16pos < pos:
      corrected += finger.offset
    else:
      break
  stdout.write corrected
  stdout.write "\t"
  stdout.write x.runeAt(corrected)
  if c.int32 == x.runeAt(corrected).int32:
    stdout.write "\tOK".green
  else:
    stdout.write "\tERR".red
  stdout.write "\n"
  if c.int >= 0x10000:
    pos += 2
  else:
    pos += 1

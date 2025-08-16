// Notably, the phrase wrapper type around each AST node 
// carries the source position information.
///|
pub struct Pos {
  file : String
  line : Int
  column : Int
}

///|
pub struct Region {
  left : Pos
  right : Pos
}

///|
pub struct Phrase[T] {
  at : Region
  it : T
}

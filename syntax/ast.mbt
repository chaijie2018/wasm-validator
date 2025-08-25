///|
enum Void {}

// Integer operations module

///|
pub enum IntUnOp {
  Clz
  Ctz
  Popcnt
  ExtendS(PackSize)
}

///|
pub enum IntBinOp {
  Add
  Sub
  Mul
  DivS
  DivU
  RemS
  RemU
  And
  Or
  Xor
  Shl
  ShrS
  ShrU
  Rotl
  Rotr
}

///|
enum IntTestOp {
  Eqz
}

///|
enum IntRelOp {
  Eq
  Ne
  LtS
  LtU
  GtS
  GtU
  LeS
  LeU
  GeS
  GeU
}

///|
pub enum IntCvtOp {
  ExtendSI32
  ExtendUI32
  WrapI64
  TruncSF32
  TruncUF32
  TruncSF64
  TruncUF64
  TruncSatSF32
  TruncSatUF32
  TruncSatSF64
  TruncSatUF64
  ReinterpretFloat
}

// Float operations module

///|
pub enum FloatUnOp {
  Neg
  Abs
  Ceil
  Floor
  Trunc
  Nearest
  Sqrt
}

///|
pub enum FloatBinOp {
  Add
  Sub
  Mul
  Div
  Min
  Max
  CopySign
}

///|
pub enum FloatTestOp {
  // Empty type as in OCaml
}

///|
pub enum FloatRelOp {
  Eq
  Ne
  Lt
  Gt
  Le
  Ge
}

///|
pub enum FloatCvtOp {
  ConvertSI32
  ConvertUI32
  ConvertSI64
  ConvertUI64
  PromoteF32
  DemoteF64
  ReinterpretInt
}

///|
pub typealias IntUnOp as I32UnOp

///|
pub typealias IntBinOp as I32BinOp

///|
pub typealias IntTestOp as I32TestOp

///|
pub typealias IntRelOp as I32RelOp

///|
pub typealias IntCvtOp as I32CvtOp

///|
pub typealias IntUnOp as I64UnOp

///|
pub typealias IntBinOp as I64BinOp

///|
pub typealias IntTestOp as I64TestOp

///|
pub typealias IntRelOp as I64RelOp

///|
pub typealias IntCvtOp as I64CvtOp

///|
pub typealias FloatUnOp as F32UnOp

///|
pub typealias FloatBinOp as F32BinOp

///|
pub typealias FloatTestOp as F32TestOp

///|
pub typealias FloatRelOp as F32RelOp

///|
pub typealias FloatCvtOp as F32CvtOp

///|
pub typealias FloatUnOp as F64UnOp

///|
pub typealias FloatBinOp as F64BinOp

///|
pub typealias FloatTestOp as F64TestOp

///|
pub typealias FloatRelOp as F64RelOp

///|
pub typealias FloatCvtOp as F64CvtOp

///|
pub typealias Op[IntTestOp, IntTestOp, FloatTestOp, FloatTestOp] as TestOp

///|
pub typealias Op[IntUnOp, IntUnOp, FloatUnOp, FloatUnOp] as UnOp

///|
pub typealias Op[IntBinOp, IntBinOp, FloatBinOp, FloatBinOp] as BinOp

///|
pub typealias Op[IntRelOp, IntRelOp, FloatRelOp, FloatRelOp] as RelOp

///|
pub typealias Op[IntCvtOp, IntCvtOp, FloatCvtOp, FloatCvtOp] as CvtOp

// V128 operations

///|
enum V128ITestOp {
  AllTrue
}

///|
enum V128IUnOp {
  Abs
  Neg
  Popcnt
}

///|
enum V128FUnOp {
  Abs
  Neg
  Sqrt
  Ceil
  Floor
  Trunc
  Nearest
}

///|
enum V128IBinOp {
  Add
  Sub
  Mul
  MinS
  MinU
  MaxS
  MaxU
  AvgrU
  AddSatS
  AddSatU
  SubSatS
  SubSatU
  DotS
  Q15MulRSatS
  ExtMulLowS
  ExtMulHighS
  ExtMulLowU
  ExtMulHighU
  Swizzle
  Shuffle(Array[Int])
  NarrowS
  NarrowU
}

///|
enum V128FBinOp {
  Add
  Sub
  Mul
  Div
  Min
  Max
  Pmin
  Pmax
}

///|
enum V128IRelOp {
  Eq
  Ne
  LtS
  LtU
  LeS
  LeU
  GtS
  GtU
  GeS
  GeU
}

///|
enum V128FRelOp {
  Eq
  Ne
  Lt
  Le
  Gt
  Ge
}

///|
enum V128ICvtOp {
  ExtendLowS
  ExtendLowU
  ExtendHighS
  ExtendHighU
  ExtAddPairwiseS
  ExtAddPairwiseU
  TruncSatSF32x4
  TruncSatUF32x4
  TruncSatSZeroF64x2
  TruncSatUZeroF64x2
}

///|
enum V128FCvtOp {
  DemoteZeroF64x2
  PromoteLowF32x4
  ConvertSI32x4
  ConvertUI32x4
}

///|
enum V128IShiftOp {
  Shl
  ShrS
  ShrU
}

///|
enum V128IBitmaskOp {
  Bitmask
}

///|
enum V128VTestOp {
  AnyTrue
}

///|
enum V128VUnOp {
  Not
}

///|
enum V128VBinOp {
  And
  Or
  Xor
  AndNot
}

///|
enum V128VTernOp {
  Bitselect
}

// Lane operations

///|
pub typealias V128LaneOp[
  V128ITestOp,
  V128ITestOp,
  V128ITestOp,
  V128ITestOp,
  Void,
  Void,
] as V128TestOp

///|
pub typealias V128LaneOp[
  V128IUnOp,
  V128IUnOp,
  V128IUnOp,
  V128IUnOp,
  V128FUnOp,
  V128FUnOp,
] as V128UnOp

///|
pub typealias V128LaneOp[
  V128IBinOp,
  V128IBinOp,
  V128IBinOp,
  V128IBinOp,
  V128FBinOp,
  V128FBinOp,
] as V128BinOp

///|
pub typealias V128LaneOp[
  V128IRelOp,
  V128IRelOp,
  V128IRelOp,
  V128IRelOp,
  V128FRelOp,
  V128FRelOp,
] as V128RelOp

///|
pub typealias V128LaneOp[
  V128ICvtOp,
  V128ICvtOp,
  V128ICvtOp,
  V128ICvtOp,
  V128FCvtOp,
  V128FCvtOp,
] as V128CvtOp

///|
pub typealias V128LaneOp[
  V128IShiftOp,
  V128IShiftOp,
  V128IShiftOp,
  V128IShiftOp,
  Void,
  Void,
] as V128ShiftOp

///|
pub typealias V128LaneOp[
  V128IBitmaskOp,
  V128IBitmaskOp,
  V128IBitmaskOp,
  V128IBitmaskOp,
  Void,
  Void,
] as V128BitmaskOp

// Splat, extract, and replace operations

///|
enum V128nSplatOp {
  Splat
}

///|
pub enum V128nExtractOp[T] {
  Extract(Int, T)
}

///|
enum V128nReplaceOp {
  Replace(Int)
}

///|
pub typealias V128LaneOp[
  V128nSplatOp,
  V128nSplatOp,
  V128nSplatOp,
  V128nSplatOp,
  V128nSplatOp,
  V128nSplatOp,
] as V128SplatOp

///|
pub typealias V128LaneOp[
  V128nExtractOp[Extension],
  V128nExtractOp[Extension],
  V128nExtractOp[Unit],
  V128nExtractOp[Unit],
  V128nExtractOp[Unit],
  V128nExtractOp[Unit],
] as V128ExtractOp

///|
pub typealias V128LaneOp[
  V128nReplaceOp,
  V128nReplaceOp,
  V128nReplaceOp,
  V128nReplaceOp,
  V128nReplaceOp,
  V128nReplaceOp,
] as V128ReplaceOp

///|
pub typealias VecOp[V128TestOp] as VecTestOp

///|
pub typealias VecOp[V128RelOp] as VecRelOp

///|
pub typealias VecOp[V128UnOp] as VecUnOp

///|
pub typealias VecOp[V128BinOp] as VecBinOp

///|
pub typealias VecOp[V128CvtOp] as VecCvtOp

///|
pub typealias VecOp[V128ShiftOp] as VecShiftOp

///|
pub typealias VecOp[V128BitmaskOp] as VecBitmaskOp

///|
pub typealias VecOp[V128VTestOp] as VecVTestOp

///|
pub typealias VecOp[V128VUnOp] as VecVUnOp

///|
pub typealias VecOp[V128VBinOp] as VecVBinOp

///|
pub typealias VecOp[V128VTernOp] as VecVTernOp

///|
pub typealias VecOp[V128SplatOp] as VecSplatOp

///|
pub typealias VecOp[V128ExtractOp] as VecExtractOp

///|
pub typealias VecOp[V128ReplaceOp] as VecReplaceOp

///|
pub struct MemOp[T, P] {
  ty : T
  align : Int
  offset : Int
  pack : P
}

///|
pub typealias MemOp[NumType, (PackSize, Extension)?] as LoadOp

///|
pub typealias MemOp[NumType, PackSize?] as StoreOp

///|
pub typealias MemOp[VecType, (PackSize, VecExtension)?] as VecLoadOp

///|
pub typealias MemOp[VecType, Unit] as VecStoreOp

///|
pub typealias (MemOp[VecType, PackSize], Int) as VecLaneOp

// Expressions

///|
pub typealias Phrase[Int] as Var

///|
pub typealias Phrase[ValuesNum] as Num

///|
pub typealias Phrase[ValuesVec] as Vec

///|
pub typealias Array[Int] as Name

///|
pub enum BlockType {
  VarBlockType(Var)
  ValBlockType(ValueType?)
}

///|
pub typealias Phrase[InstrType] as Instr

///|
pub enum InstrType {
  // Control Flow Instructions
  Unreachable // trap unconditionally
  Nop // do nothing
  Drop // forget a value
  Select(Array[ValueType]?) // branchless conditional
  Block(BlockType, Array[Instr]) // execute in sequence
  Loop(BlockType, Array[Instr]) // loop header
  If(BlockType, Array[Instr], Array[Instr]) // conditional

  // Branch Instructions
  Br(Var) // break to n-th surrounding label
  BrIf(Var) // conditional break
  BrTable(Array[Var], Var) // indexed break
  Return // break from function body

  // Function Call Instructions
  Call(Var) // call function
  CallIndirect(Var, Var) // call function through table

  // Local Variable Instructions
  LocalGet(Var) // read local variable
  LocalSet(Var) // write local variable
  LocalTee(Var) // write local variable and keep value

  // Global Variable Instructions
  GlobalGet(Var) // read global variable
  GlobalSet(Var) // write global variable

  // Table Operation Instructions
  TableGet(Var) // read table element
  TableSet(Var) // write table element
  TableSize(Var) // size of table
  TableGrow(Var) // grow table
  TableFill(Var) // fill table range with value
  TableCopy(Var, Var) // copy table range
  TableInit(Var, Var) // initialize table range from segment
  ElemDrop(Var) // drop passive element segment

  // Memory Operation Instructions
  Load(LoadOp) // read memory at address
  Store(StoreOp) // write memory at address
  VecLoad(VecLoadOp) // read vector memory at address
  VecStore(VecStoreOp) // write vector memory at address
  VecLoadLane(VecLaneOp) // read single lane at address
  VecStoreLane(VecLaneOp) // write single lane to address
  MemorySize // size of memory
  MemoryGrow // grow memory
  MemoryFill // fill memory range with value
  MemoryCopy // copy memory ranges
  MemoryInit(Var) // initialize memory range from segment
  DataDrop(Var) // drop passive data segment

  // Reference Instructions
  RefNull(RefType) // null reference
  RefFunc(Var) // function reference
  RefIsNull // null test

  // Numeric Instructions
  Const(Num) // constant
  Test(TestOp) // numeric test
  Compare(RelOp) // numeric comparison
  Unary(UnOp) // unary numeric operator
  Binary(BinOp) // binary numeric operator
  Convert(CvtOp) // conversion

  // Vector Instructions
  VecConst(Vec) // vector constant
  VecTest(VecTestOp) // vector test
  VecCompare(VecRelOp) // vector comparison
  VecUnary(VecUnOp) // unary vector operator
  VecBinary(VecBinOp) // binary vector operator
  VecConvert(VecCvtOp) // vector conversion
  VecShift(VecShiftOp) // vector shifts
  VecBitmask(VecBitmaskOp) // vector masking
  VecTestBits(VecVTestOp) // vector bit test
  VecUnaryBits(VecVUnOp) // unary bit vector operator
  VecBinaryBits(VecVBinOp) // binary bit vector operator
  VecTernaryBits(VecVTernOp) // ternary bit vector operator
  VecSplat(VecSplatOp) // number to vector conversion
  VecExtract(VecExtractOp) // extract lane from vector
  VecReplace(VecReplaceOp) // replace lane in vector
}

// Globals & Functions

///|
pub typealias Phrase[Array[Instr]] as Const

///|
struct GlobalT {
  gtype : GlobalType
  ginit : Const
}

///|
pub typealias Phrase[GlobalT] as Global

///|
pub struct FuncT {
  ftype : Var
  locals : Array[ValueType]
  body : Array[Instr]
}

///|
pub typealias Phrase[FuncT] as Func

// Tables & Memories

///|
pub struct TableT {
  ttype : TableType
}

///|
pub typealias Phrase[TableT] as Table

///|
pub struct MemoryT {
  mtype : MemoryType
}

///|
pub typealias Phrase[MemoryT] as Memory

///|
pub struct ActiveSegment {
  index : Var
  offset : Const
}

///|
pub enum SegmentModeT {
  Passive
  Active(ActiveSegment)
  Declarative
}

///|
pub typealias Phrase[SegmentModeT] as SegmentMode

///|
pub struct ElemSegmentT {
  etype : RefType
  einit : Array[Const]
  emode : SegmentMode
}

///|
pub typealias Phrase[ElemSegmentT] as ElemSegment

///|
pub struct DataSegmentT {
  dinit : String
  dmode : SegmentMode
}

///|
pub typealias Phrase[DataSegmentT] as DataSegment

// Modules

///|
pub typealias Phrase[FuncType] as Type_

///|
enum ExportDescT {
  FuncExport(Var)
  TableExport(Var)
  MemoryExport(Var)
  GlobalExport(Var)
}

///|
typealias Phrase[ExportDescT] as ExportDesc

///|
struct ExportT {
  name : Name
  edesc : ExportDesc
}

///|
pub typealias Phrase[ExportT] as Export

///|
pub struct ImportT {
  module_name : Name
  item_name : Name
  idesc : ImportDesc
}

///|
pub typealias Phrase[ImportT] as Import

///|
enum ImportDescT {
  FuncImport(Var)
  TableImport(TableType)
  MemoryImport(MemoryType)
  GlobalImport(GlobalType)
}

///|
pub typealias Phrase[ImportDescT] as ImportDesc

///|
struct StartT {
  sfunc : Var
}

///|
pub typealias Phrase[StartT] as Start

///|
pub struct ModuleT {
  types : Array[Type_]
  globals : Array[Global]
  tables : Array[Table]
  memories : Array[Memory]
  funcs : Array[Func]
  start : Start?
  elems : Array[ElemSegment]
  datas : Array[DataSegment]
  imports : Array[Import]
  exports : Array[Export]
}

///|
pub typealias Phrase[ModuleT] as Module_

// Auxiliary functions

///|
let empty_module : ModuleT = {
  types: [],
  globals: [],
  tables: [],
  memories: [],
  funcs: [],
  start: None,
  elems: [],
  datas: [],
  imports: [],
  exports: [],
}

///|
fn func_type_for(m : Module_, x : Var) -> FuncType {
  let types = m.it.types
  let index = x.it
  types[index].it
}

///|
fn import_type(m : Module_, im : Import) -> ExternType {
  let idesc = im.it.idesc
  match idesc.it {
    FuncImport(x) => ExternFuncType(func_type_for(m, x))
    TableImport(t) => ExternTableType(t)
    MemoryImport(t) => ExternMemoryType(t)
    GlobalImport(t) => ExternGlobalType(t)
  }
}

///|
pub fn export_type(m : Module_, ex : Export) -> ExternType {
  let edesc = ex.it.edesc
  let its = m.it.imports.map(fn(im) { import_type(m, im) })
  match edesc.it {
    FuncExport(x) => {
      let import_funcs = funcs(its)
      let module_funcs = m.it.funcs.map(fn(f) { func_type_for(m, f.it.ftype) })
      let all_funcs = [..import_funcs, ..module_funcs]
      let index = x.it
      ExternFuncType(all_funcs[index])
    }
    TableExport(x) => {
      let import_tables = tables(its)
      let module_tables = m.it.tables.map(fn(t) { t.it.ttype })
      let all_tables = [..import_tables, ..module_tables]
      let index = x.it
      ExternTableType(all_tables[index])
    }
    MemoryExport(x) => {
      let import_memories = memories(its)
      let module_memories = m.it.memories.map(fn(mem) { mem.it.mtype })
      let all_memories = [..import_memories, ..module_memories]
      let index = x.it
      ExternMemoryType(all_memories[index])
    }
    GlobalExport(x) => {
      let import_globals = globals(its)
      let module_globals = m.it.globals.map(fn(g) { g.it.gtype })
      let all_globals = [..import_globals, ..module_globals]
      let index = x.it
      ExternGlobalType(all_globals[index])
    }
  }
}

// Unicode Name to String (with Escapes)

///|
pub fn string_of_name(name : Array[Int]) -> String {
  let result = []
  for uc in name {
    if uc < 0x20 || uc >= 0x7f {
      result.push("\\u{\{uc}}")
    } else {
      let c = uc.to_char()
      if c is Some(c) {
        if c == '\"' || c == '\\' {
          result.push("\\")
        }
        result.push(c.to_string())
      }
    }
  }
  result.join("")
}

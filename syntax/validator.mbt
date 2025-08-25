///|
pub struct Context {
  types : Array[FuncType]
  funcs : Array[FuncType]
  tables : Array[TableType]
  memories : Array[MemoryType]
  globals : Array[GlobalType]
  elems : Array[RefType]
  datas : Array[Unit]
  locals : Array[ValueType]
  results : Array[ValueType]
  labels : Array[ResultType]
  refs : FreeVars
}

///|
let empty_context : Context = {
  types: [],
  funcs: [],
  tables: [],
  memories: [],
  globals: [],
  elems: [],
  datas: [],
  locals: [],
  results: [],
  labels: [],
  refs: empty_free_vars,
}

///|
pub fn[T] lookup(
  category : String,
  array : Array[T],
  x : Phrase[Int],
) -> T raise {
  let it = x.it
  if it < 0 || it >= array.length() {
    let msg = "unknown" + category + " " + it.to_string()
    fail(msg)
  }
  array[it]
}

///|
pub fn type_(c : Context, x : Phrase[Int]) -> FuncType raise {
  lookup("type", c.types, x)
}

///|
pub fn func(c : Context, x : Phrase[Int]) -> FuncType raise {
  lookup("function", c.funcs, x)
}

///|
pub fn table(c : Context, x : Phrase[Int]) -> TableType raise {
  lookup("table", c.tables, x)
}

///|
pub fn memory(c : Context, x : Phrase[Int]) -> MemoryType raise {
  lookup("memory", c.memories, x)
}

///|
pub fn global(c : Context, x : Phrase[Int]) -> GlobalType raise {
  lookup("global", c.globals, x)
}

///|
pub fn elem(c : Context, x : Phrase[Int]) -> RefType raise {
  lookup("elem segment", c.elems, x)
}

///|
pub fn data(c : Context, x : Phrase[Int]) -> Unit raise {
  lookup("data segment", c.datas, x)
}

///|
pub fn local(c : Context, x : Phrase[Int]) -> ValueType raise {
  lookup("local", c.locals, x)
}

///|
pub fn label(c : Context, x : Phrase[Int]) -> ResultType raise {
  lookup("label", c.labels, x)
}

///|
fn refer(category : String, s : Set[Int], x : Var) -> Unit raise {
  if not(s.contains(x.it)) {
    fail("undeclared " + category + " reference " + x.it.to_string())
  }
}

///|
pub fn refer_func(c : Context, x : Var) -> Unit raise {
  refer("function", c.refs.funcs, x)
}

///|
pub fn require(b : Bool, at : Phrase[Int], s : String) -> Unit raise {
  if !b {
    fail("require failed")
  }
}

///|
pub enum Ellipses {
  NoEllipses
  Ellipses
} derive(Show, Eq)

///|
pub typealias (Ellipses, Array[ValueType?]) as InferResultType

///|
pub struct OpType {
  ins : InferResultType
  outs : InferResultType
}

///|
pub fn known(ts : Array[ValueType]) -> Array[ValueType?] {
  ts.map(fn(t) { Some(t) })
}

///|
pub fn stack(ts : Array[ValueType]) -> InferResultType {
  (NoEllipses, known(ts))
}

// Custom operator for creating OpType without ellipses and without known wrapper
// In OCaml source code, this function is defined as -~>

///|
pub fn op_no_ellipses(
  ts1 : Array[ValueType?],
  ts2 : Array[ValueType?],
) -> OpType {
  { ins: (NoEllipses, ts1), outs: (NoEllipses, ts2) }
}

// Custom operator for creating OpType without ellipses and with known wrapper
// In OCaml source code, this function is defined as -->

///|
pub fn op_known(ts1 : Array[ValueType], ts2 : Array[ValueType]) -> OpType {
  { ins: (NoEllipses, known(ts1)), outs: (NoEllipses, known(ts2)) }
}

// Custom operator for creating OpType with ellipses and without known wrapper
// In OCaml source code, this function is defined as -~>...

///|
pub fn op_ellipses(ts1 : Array[ValueType?], ts2 : Array[ValueType?]) -> OpType {
  { ins: (Ellipses, ts1), outs: (Ellipses, ts2) }
}

// Custom operator for creating OpType with ellipses and with known wrapper
// In OCaml source code, this function is defined as -->...

///|
pub fn op_ellipses_known(
  ts1 : Array[ValueType],
  ts2 : Array[ValueType],
) -> OpType {
  { ins: (Ellipses, known(ts1)), outs: (Ellipses, known(ts2)) }
}

///|
/// String conversion functions for WebAssembly types
fn string_of_num_type(t : NumType) -> String {
  match t {
    I32Type => "i32"
    I64Type => "i64"
    F32Type => "f32"
    F64Type => "f64"
  }
}

///|
fn string_of_vec_type(t : VecType) -> String {
  match t {
    V128Type => "v128"
  }
}

///|
fn string_of_ref_type(t : RefType) -> String {
  match t {
    FuncRefType => "funcref"
    ExternRefType => "externref"
  }
}

///|
fn string_of_refed_type(t : RefType) -> String {
  match t {
    FuncRefType => "func"
    ExternRefType => "extern"
  }
}

///|
fn string_of_value_type(t : ValueType) -> String {
  match t {
    NumType(nt) => string_of_num_type(nt)
    VecType(vt) => string_of_vec_type(vt)
    RefType(rt) => string_of_ref_type(rt)
  }
}

///|
fn string_of_value_types(ts : Array[ValueType]) -> String {
  match ts {
    [t] => string_of_value_type(t)
    _ => "[" + ts.map(string_of_value_type).join(" ") + "]"
  }
}

///|
fn string_of_result_type(ts : Array[ValueType]) -> String {
  "[" + ts.map(string_of_value_type).join(" ") + "]"
}

///|
fn string_of_infer_type(t : ValueType?) -> String {
  match t {
    Some(value_type) => string_of_value_type(value_type)
    None => "_"
  }
}

///|
fn string_of_infer_types(ts : Array[ValueType?]) -> String {
  let strings = ts.map(fn(t) { string_of_infer_type(t) })
  "[" + strings.join(" ") + "]"
}

///|
/// Stack type checking functions for WebAssembly validation
fn eq_ty(t1 : ValueType?, t2 : ValueType?) -> Bool {
  match (t1, t2) {
    (Some(a), Some(b)) => a == b
    (None, _) => true
    (_, None) => true
  }
}

///|
fn check_stack(ts1 : Array[ValueType?], ts2 : Array[ValueType?]) -> Unit raise {
  let mut all_match = true
  if ts1.length() == ts2.length() {
    for i = 0; i < ts1.length() && all_match; i = i + 1 {
      if !eq_ty(ts1[i], ts2[i]) {
        all_match = false
      }
    }
  }
  if !all_match || ts1.length() != ts2.length() {
    fail(
      "type mismatch: instruction requires " +
      string_of_infer_types(ts1) +
      " but stack has " +
      string_of_infer_types(ts2),
    )
  }
}

///|
fn array_drop(arr : Array[ValueType?], n : Int) -> Array[ValueType?] {
  let result : Array[ValueType?] = []
  for i = n; i < arr.length(); i = i + 1 {
    result.push(arr[i])
  }
  result
}

///|
fn array_take(arr : Array[ValueType?], n : Int) -> Array[ValueType?] {
  let result : Array[ValueType?] = []
  for i = 0; i < n && i < arr.length(); i = i + 1 {
    result.push(arr[i])
  }
  result
}

///|
/// stack2 is the current actual stack state, stack1 is the one to be popped.
/// The tail element of the array is the top of the stack.
/// 
/// See the test function 'pop' below for an example of how to use this function.
pub fn pop(
  stack1 : InferResultType,
  stack2 : InferResultType,
) -> InferResultType raise {
  let (ellip1, ts1) = stack1
  let (ellip2, ts2) = stack2
  let n1 = ts1.length()
  let n2 = ts2.length()
  let n = if n1 < n2 { n1 } else { n2 }
  let n3 = match ellip2 {
    Ellipses => n1 - n
    NoEllipses => 0
  }

  // Create array with n3 None values and append the relevant part of ts2
  let none_array = Array::make(n3, None)
  let dropped_ts2 = array_drop(ts2, n2 - n)
  let check_ts2 = none_array + dropped_ts2
  check_stack(ts1, check_ts2)
  let result_ts2 = match ellip1 {
    Ellipses => []
    NoEllipses => array_take(ts2, n2 - n)
  }
  (ellip2, result_ts2)
}

///|
test "pop" {
  let ts1 = (NoEllipses, [Some(NumType(I64Type)), Some(NumType(I32Type))])
  let ts2 = (
    NoEllipses,
    [Some(NumType(F32Type)), Some(NumType(I64Type)), Some(NumType(I32Type))],
  )
  let result = pop(ts1, ts2)
  let (ellip, arr) = result
  inspect(ellip, content="NoEllipses")
  inspect(arr, content="[Some(NumType(F32Type))]")
}

///|
/// Push stack1 onto stack2.
pub fn push(
  stack1 : InferResultType,
  stack2 : InferResultType,
) -> InferResultType raise {
  let (ellip1, types1) = stack1
  let (ellip2, types2) = stack2
  assert_true(ellip1 == NoEllipses || types2.is_empty())
  let result_ellip = match (ellip1, ellip2) {
    (Ellipses, _) => Ellipses
    (_, Ellipses) => Ellipses
    _ => NoEllipses
  }
  let result_types = types2 + types1
  (result_ellip, result_types)
}

///|
pub fn peek(index : Int, stack : InferResultType) -> ValueType? {
  let (_, types) = stack
  let types_cp = types.copy()
  types_cp[:].rev_inplace()
  types_cp[index]
}

// Type Synthesis

///|
pub fn[T1, T2, T3, T4, T5, T6] type_vec_lane(
  op : VecOp[V128LaneOp[T1, T2, T3, T4, T5, T6]],
) -> NumType {
  match op {
    V128(laneop) => type_of_lane(laneop)
  }
}

///|
pub fn type_cvtop(
  value : Op[IntCvtOp, IntCvtOp, FloatCvtOp, FloatCvtOp],
) -> (NumType, NumType) raise {
  match value {
    I32(cvtop) => {
      let source_type = match cvtop {
        IntCvtOp::ExtendSI32 | IntCvtOp::ExtendUI32 =>
          fail("invalid conversion")
        IntCvtOp::WrapI64 => NumType::I64Type
        IntCvtOp::TruncSF32
        | IntCvtOp::TruncUF32
        | IntCvtOp::TruncSatSF32
        | IntCvtOp::TruncSatUF32
        | IntCvtOp::ReinterpretFloat => NumType::F32Type
        IntCvtOp::TruncSF64
        | IntCvtOp::TruncUF64
        | IntCvtOp::TruncSatSF64
        | IntCvtOp::TruncSatUF64 => NumType::F64Type
      }
      (source_type, NumType::I32Type)
    }
    I64(cvtop) => {
      let source_type = match cvtop {
        IntCvtOp::ExtendSI32 | IntCvtOp::ExtendUI32 => NumType::I32Type
        IntCvtOp::WrapI64 => fail("invalid conversion")
        IntCvtOp::TruncSF32
        | IntCvtOp::TruncUF32
        | IntCvtOp::TruncSatSF32
        | IntCvtOp::TruncSatUF32 => NumType::F32Type
        IntCvtOp::TruncSF64
        | IntCvtOp::TruncUF64
        | IntCvtOp::TruncSatSF64
        | IntCvtOp::TruncSatUF64
        | IntCvtOp::ReinterpretFloat => NumType::F64Type
      }
      (source_type, NumType::I64Type)
    }
    F32(cvtop) => {
      let source_type = match cvtop {
        FloatCvtOp::ConvertSI32
        | FloatCvtOp::ConvertUI32
        | FloatCvtOp::ReinterpretInt => NumType::I32Type
        FloatCvtOp::ConvertSI64 | FloatCvtOp::ConvertUI64 => NumType::I64Type
        FloatCvtOp::PromoteF32 => fail("invalid conversion")
        FloatCvtOp::DemoteF64 => NumType::F64Type
      }
      (source_type, NumType::F32Type)
    }
    F64(cvtop) => {
      let source_type = match cvtop {
        FloatCvtOp::ConvertSI32 | FloatCvtOp::ConvertUI32 => NumType::I32Type
        FloatCvtOp::ConvertSI64
        | FloatCvtOp::ConvertUI64
        | FloatCvtOp::ReinterpretInt => NumType::I64Type
        FloatCvtOp::PromoteF32 => NumType::F32Type
        FloatCvtOp::DemoteF64 => fail("invalid conversion")
      }
      (source_type, NumType::F64Type)
    }
  }
}

///|
pub fn[T1, T2, T3, T4, T5, T6] num_lanes(
  vecop : VecOp[V128LaneOp[T1, T2, T3, T4, T5, T6]],
) -> Int {
  match vecop {
    V128(laneop) => num_of_lanes(laneop)
  }
}

// This function extracts the lane index from a vector extract operation

///|
pub fn[T1, T2, T3, T4, T5, T6] lane_extractop(
  vec : VecOp[
    V128LaneOp[
      V128nExtractOp[T1],
      V128nExtractOp[T2],
      V128nExtractOp[T3],
      V128nExtractOp[T4],
      V128nExtractOp[T5],
      V128nExtractOp[T6],
    ],
  ],
) -> Int {
  match vec {
    V128(extractop) =>
      match extractop {
        I8x16(V128nExtractOp::Extract(i, _)) => i
        I16x8(V128nExtractOp::Extract(i, _)) => i
        I32x4(V128nExtractOp::Extract(i, _)) => i
        I64x2(V128nExtractOp::Extract(i, _)) => i
        F32x4(V128nExtractOp::Extract(i, _)) => i
        F64x2(V128nExtractOp::Extract(i, _)) => i
      }
  }
}

///|
pub fn lane_replaceop(vec : VecOp[V128ReplaceOp]) -> Int {
  match vec {
    V128(replaceop) =>
      match replaceop {
        I8x16(V128nReplaceOp::Replace(i)) => i
        I16x8(V128nReplaceOp::Replace(i)) => i
        I32x4(V128nReplaceOp::Replace(i)) => i
        I64x2(V128nReplaceOp::Replace(i)) => i
        F32x4(V128nReplaceOp::Replace(i)) => i
        F64x2(V128nReplaceOp::Replace(i)) => i
      }
  }
}

///|
/// Expressions
pub fn check_pack(size : PackSize, t_size : Int) -> Unit raise {
  if packed_size(size) >= t_size {
    fail("invalid sign extension")
  }
}

///|
pub fn[T3, T4] check_unop(unop : Op[IntUnOp, IntUnOp, T3, T4]) -> Unit raise {
  match unop {
    I32(ExtendS(sz)) | I64(ExtendS(sz)) =>
      check_pack(sz, num_size(type_of_num(unop)))
    _ => ()
  }
}

///|
pub fn check_vec_binop(binop : VecOp[V128BinOp]) -> Unit raise {
  if binop is V128(I8x16(Shuffle(indices))) {
    for index in indices {
      if index < 0 || index >= 32 {
        fail("invalid lane index")
      }
    }
  }
}

///|
pub fn[T, P] check_memop(
  c : Context,
  memop : MemOp[T, P],
  ty_size : (T) -> Int,
  get_sz : (P) -> PackSize?,
) -> Unit raise {
  // let _mt = memory c (0l @@ at) in
  let size = match get_sz(memop.pack) {
    None => ty_size(memop.ty)
    Some(sz) => {
      check_pack(sz, ty_size(memop.ty))
      packed_size(sz)
    }
  }
  if 1 << memop.align > size {
    fail("alignment must not be larger than natural")
  }
}

///|
/// Conventions:
///   c  : context
///   e  : instr
///   es : instr list
///   v  : value
///   t  : value_type var
///   ts : result_type
///   x  : variable
///
/// Note: To deal with the non-determinism in some of the declarative rules,
/// the function takes the current stack `s` as an additional argument, allowing
/// it to "peek" when it would otherwise have to guess an input type.
pub fn check_block_type(c : Context, bt : BlockType) -> FuncType raise {
  match bt {
    VarBlockType(x) => type_(c, x)
    ValBlockType(None) => FuncType([], [])
    ValBlockType(Some(t)) => FuncType([], [t])
  }
}

///|
pub fn check_instr(c : Context, e : Instr, s : InferResultType) -> OpType raise {
  match e.it {
    Unreachable => op_ellipses_known([], [])
    Nop => op_known([], [])
    Drop => op_no_ellipses([peek(0, s)], [])
    Select(None) => {
      let t = peek(1, s)
      let condition = match t {
        None => true
        Some(t) => is_num_type(t) || is_vec_type(t)
      }
      if condition == false {
        fail(
          "type mismatch: instruction requires numeric or vector type" +
          " but stack has " +
          string_of_infer_type(t),
        )
      }
      op_no_ellipses([t, t, Some(NumType(I32Type))], [t])
    }
    Select(Some(ts)) => {
      if ts.length() != 1 {
        fail("invalid result arity other than 1 is not (yet) allowed")
      }
      let input_types = [..ts, ..ts, NumType(I32Type)]
      op_known(input_types, ts)
    }
    Block(bt, es) => {
      let FuncType(ts1, ts2) = check_block_type(c, bt)
      let new_context = { ..c, labels: [ts1] + c.labels }
      check_block(new_context, es, FuncType(ts1, ts2), e.at)
      op_known(ts1, ts2)
    }
    Loop(bt, es) => {
      let FuncType(ts1, ts2) = check_block_type(c, bt)
      let new_context = { ..c, labels: [ts1] + c.labels }
      check_block(new_context, es, FuncType(ts1, ts2), e.at)
      op_known(ts1, ts2)
    }
    If(bt, es1, es2) => {
      let FuncType(ts1, ts2) = check_block_type(c, bt)
      let new_context = { ..c, labels: [ts2] + c.labels }
      check_block(new_context, es1, FuncType(ts1, ts2), e.at)
      check_block(new_context, es2, FuncType(ts1, ts2), e.at)
      let input_types = [..ts1, NumType(I32Type)]
      op_known(input_types, ts2)
    }
    Br(x) => op_ellipses_known(label(c, x), [])
    BrIf(x) => {
      let label_types = label(c, x)
      let input_types = [..label_types, NumType(I32Type)]
      op_known(input_types, label_types)
    }
    BrTable(xs, x) => {
      let n = label(c, x).length()
      let ts = Array::makei(n, i => peek(n - 1 - i, s))
      check_stack(ts, known(label(c, x)))
      for x_prime in xs {
        check_stack(ts, known(label(c, x_prime)))
      }
      let input_types = [..ts, Some(NumType(I32Type))]
      op_ellipses(input_types, [])
    }
    Return => op_ellipses_known(c.results, [])
    Call(x) => {
      let FuncType(ts1, ts2) = func(c, x)
      op_known(ts1, ts2)
    }
    CallIndirect(x, y) => {
      let { limits: _, ref_type: t } = table(c, x)
      let FuncType(ts1, ts2) = type_(c, y)
      if t != FuncRefType {
        fail(
          "type mismatch: instruction requires table of functions" +
          " but table has " +
          string_of_ref_type(t),
        )
      }
      let input_types = [..ts1, NumType(I32Type)]
      op_known(input_types, ts2)
    }
    LocalGet(x) => op_known([], [local(c, x)])
    LocalSet(x) => op_known([local(c, x)], [])
    LocalTee(x) => op_known([local(c, x)], [local(c, x)])
    GlobalGet(x) => {
      let { value_type: t, mutability: _ } = global(c, x)
      op_known([], [t])
    }
    GlobalSet(x) => {
      let { value_type: t, mutability: mutable } = global(c, x)
      if not(mutable is Mutable) {
        fail("global is immutable")
      }
      op_known([t], [])
    }
    TableGet(x) => {
      let { limits: _, ref_type: t } = table(c, x)
      op_known([NumType(I32Type)], [RefType(t)])
    }
    TableSet(x) => {
      let { limits: _, ref_type: t } = table(c, x)
      op_known([NumType(I32Type), RefType(t)], [])
    }
    TableSize(x) => {
      let _tt = table(c, x)
      op_known([], [NumType(I32Type)])
    }
    TableGrow(x) => {
      let { limits: _, ref_type: t } = table(c, x)
      op_known([RefType(t), NumType(I32Type)], [NumType(I32Type)])
    }
    TableFill(x) => {
      let { limits: _, ref_type: t } = table(c, x)
      op_known([NumType(I32Type), RefType(t), NumType(I32Type)], [])
    }
    TableCopy(x, y) => {
      let { limits: _, ref_type: t1 } = table(c, x)
      let { limits: _, ref_type: t2 } = table(c, y)
      if t1 != t2 {
        fail(
          "type mismatch: source element type " +
          string_of_ref_type(t1) +
          " does not match destination element type " +
          string_of_ref_type(t2),
        )
      }
      op_known([NumType(I32Type), NumType(I32Type), NumType(I32Type)], [])
    }
    TableInit(x, y) => {
      let { limits: _, ref_type: t1 } = table(c, x)
      let t2 = elem(c, y)
      if t1 != t2 {
        fail(
          "type mismatch: element segment's type " +
          string_of_ref_type(t1) +
          " does not match table's element type " +
          string_of_ref_type(t2),
        )
      }
      op_known([NumType(I32Type), NumType(I32Type), NumType(I32Type)], [])
    }
    ElemDrop(x) => {
      let _ = elem(c, x)
      op_known([], [])
    }
    Load(memop) => {
      check_memop(c, memop, num_size, fn(x) { x.map(fn(pair) { pair.0 }) })
      op_known([NumType(I32Type)], [NumType(memop.ty)])
    }
    Store(memop) => {
      check_memop(c, memop, num_size, fn(sz) { sz })
      op_known([NumType(I32Type), NumType(memop.ty)], [])
    }
    VecLoad(memop) => {
      check_memop(c, memop, vec_size, fn(x) { x.map(fn(pair) { pair.0 }) })
      op_known([NumType(I32Type)], [VecType(memop.ty)])
    }
    VecStore(memop) => {
      check_memop(c, memop, vec_size, fn(_) { None })
      op_known([NumType(I32Type), VecType(memop.ty)], [])
    }
    VecLoadLane((memop, i)) => {
      check_memop(c, memop, vec_size, fn(sz) { Some(sz) })
      if not(i < vec_size(memop.ty) / packed_size(memop.pack)) {
        fail("invalid lane index")
      }
      op_known([NumType(I32Type), VecType(memop.ty)], [VecType(memop.ty)])
    }
    VecStoreLane((memop, i)) => {
      check_memop(c, memop, vec_size, fn(sz) { Some(sz) })
      if not(i < vec_size(memop.ty) / packed_size(memop.pack)) {
        fail("invalid lane index")
      }
      op_known([NumType(I32Type), VecType(memop.ty)], [])
    }
    MemorySize => {
      let _mt = memory(c, at_location(0, e.at))
      op_known([], [NumType(I32Type)])
    }
    MemoryGrow => {
      let _mt = memory(c, at_location(0, e.at))
      op_known([NumType(I32Type)], [NumType(I32Type)])
    }
    MemoryFill => {
      let _ = memory(c, at_location(0, e.at))
      op_known([NumType(I32Type), NumType(I32Type), NumType(I32Type)], [])
    }
    MemoryCopy => {
      let _ = memory(c, at_location(0, e.at))
      op_known([NumType(I32Type), NumType(I32Type), NumType(I32Type)], [])
    }
    MemoryInit(x) => {
      let _ = memory(c, at_location(0, e.at))
      let _ = data(c, x)
      op_known([NumType(I32Type), NumType(I32Type), NumType(I32Type)], [])
    }
    DataDrop(x) => {
      let _ = data(c, x)
      op_known([], [])
    }
    RefNull(t) => op_known([], [RefType(t)])
    RefIsNull => {
      let t = peek(0, s)
      if not(
          match t {
            None => true
            Some(t) => is_ref_type(t)
          },
        ) {
        fail(
          "type mismatch: instruction requires reference type" +
          " but stack has " +
          string_of_infer_type(t),
        )
      }
      op_no_ellipses([t], [Some(NumType(I32Type))])
    }
    RefFunc(x) => {
      let _ = func(c, x)
      refer_func(c, x)
      op_known([], [RefType(FuncRefType)])
    }
    Const(v) => {
      let t = NumType(type_of_num(v.it))
      op_known([], [t])
    }
    Test(testop) => {
      let t = NumType(type_of_num(testop))
      op_known([t], [NumType(I32Type)])
    }
    Compare(relop) => {
      let t = NumType(type_of_num(relop))
      op_known([t, t], [NumType(I32Type)])
    }
    Unary(unop) => {
      check_unop(unop)
      let t = NumType(type_of_num(unop))
      op_known([t], [t])
    }
    Binary(binop) => {
      let t = NumType(type_of_num(binop))
      op_known([t, t], [t])
    }
    Convert(cvtop) => {
      let (t1, t2) = type_cvtop(cvtop)
      op_known([NumType(t1)], [NumType(t2)])
    }
    VecConst(v) => {
      let t = VecType(type_of_vec(v.it))
      op_known([], [t])
    }
    VecTest(testop) => {
      let t = VecType(type_of_vec(testop))
      op_known([t], [NumType(I32Type)])
    }
    VecUnary(unop) => {
      let t = VecType(type_of_vec(unop))
      op_known([t], [t])
    }
    VecBinary(binop) => {
      check_vec_binop(binop)
      let t = VecType(type_of_vec(binop))
      op_known([t, t], [t])
    }
    VecCompare(relop) => {
      let t = VecType(type_of_vec(relop))
      op_known([t, t], [t])
    }
    VecConvert(cvtop) => {
      let t = VecType(type_of_vec(cvtop))
      op_known([t], [t])
    }
    VecShift(shiftop) => {
      let t = VecType(type_of_vec(shiftop))
      op_known([t, NumType(I32Type)], [VecType(V128Type)])
    }
    VecBitmask(bitmaskop) => {
      let t = VecType(type_of_vec(bitmaskop))
      op_known([t], [NumType(I32Type)])
    }
    VecTestBits(vtestop) => {
      let t = VecType(type_of_vec(vtestop))
      op_known([t], [NumType(I32Type)])
    }
    VecUnaryBits(vunop) => {
      let t = VecType(type_of_vec(vunop))
      op_known([t], [t])
    }
    VecBinaryBits(vbinop) => {
      let t = VecType(type_of_vec(vbinop))
      op_known([t, t], [t])
    }
    VecTernaryBits(vternop) => {
      let t = VecType(type_of_vec(vternop))
      op_known([t, t, t], [t])
    }
    VecSplat(splatop) => {
      let t1 = type_vec_lane(splatop)
      let t2 = VecType(type_of_vec(splatop))
      op_known([NumType(t1)], [t2])
    }
    VecExtract(extractop) => {
      let t = VecType(type_of_vec(extractop))
      let t2 = type_vec_lane(extractop)
      if lane_extractop(extractop) >= num_lanes(extractop) {
        fail("invalid lane index")
      }
      op_known([t], [NumType(t2)])
    }
    VecReplace(replaceop) => {
      let t = VecType(type_of_vec(replaceop))
      let t2 = type_vec_lane(replaceop)
      if lane_replaceop(replaceop) >= num_lanes(replaceop) {
        fail("invalid lane index")
      }
      op_known([t, NumType(t2)], [t])
    }
  }
}

///|
pub fn check_seq(
  c : Context,
  s : InferResultType,
  es : Array[Instr],
) -> InferResultType raise {
  match es.length() {
    0 => s
    _ => {
      let (es_init, e_last) = split_last(es)
      let s_prime = check_seq(c, s, es_init)
      let op_type = check_instr(c, e_last, s_prime)
      push(op_type.outs, pop(op_type.ins, s_prime))
    }
  }
}

///|
pub fn check_block(
  c : Context,
  es : Array[Instr],
  ft : FuncType,
  at : Region,
) -> Unit raise {
  let FuncType(ts1, ts2) = ft
  let s = check_seq(c, stack(ts1), es)
  let s_prime = pop(stack(ts2), s)
  if not(s_prime.1.is_empty()) {
    fail(
      "type mismatch: block requires " +
      string_of_result_type(ts2) +
      " but stack has " +
      string_of_infer_types(s.1),
    )
  }
}

///|
fn[T] split_last(arr : Array[T]) -> (Array[T], T) {
  let len = arr.length()
  (arr[0:len - 1].to_array(), arr[len - 1])
}

///|
fn at_location(value : Int, region : Region) -> Var {
  { it: value, at: region }
}

// Types

///|
pub fn check_limits(
  limits : Limits,
  range : UInt,
  at : Region,
  msg : String,
) -> Unit raise {
  if limits.min > range {
    fail(msg)
  }
  match limits.max {
    None => ()
    Some(max) => {
      if max > range {
        fail(msg)
      }
      if limits.min > max {
        fail("size minimum must not be greater than maximum")
      }
    }
  }
}

///|
pub fn check_num_type(t : NumType, at : Region) -> Unit {
  ()
}

///|
pub fn check_vec_type(t : VecType, at : Region) -> Unit {
  ()
}

///|
pub fn check_ref_type(t : RefType, at : Region) -> Unit {
  ()
}

///|
pub fn check_value_type(t : ValueType, at : Region) -> Unit {
  match t {
    NumType(t_inner) => check_num_type(t_inner, at)
    VecType(t_inner) => check_vec_type(t_inner, at)
    RefType(t_inner) => check_ref_type(t_inner, at)
  }
}

///|
pub fn check_func_type(ft : FuncType, at : Region) -> Unit {
  let FuncType(ts1, ts2) = ft
  ts1.each(fn(t) { check_value_type(t, at) })
  ts2.each(fn(t) { check_value_type(t, at) })
}

///|
pub fn check_table_type(tt : TableType, at : Region) -> Unit raise {
  let { limits: lim, ref_type: t } = tt
  check_limits(lim, 0xFFFF_FFFF_U, at, "table size must be at most 2^32-1")
  check_ref_type(t, at)
}

///|
pub fn check_memory_type(mt : MemoryType, at : Region) -> Unit raise {
  let { limits: lim } = mt
  check_limits(
    lim, 0x1_0000_U, at, "memory size must be at most 65536 pages (4GiB)",
  )
}

///|
pub fn check_global_type(gt : GlobalType, at : Region) -> Unit {
  let { value_type: t, mutability: _ } = gt
  check_value_type(t, at)
}

///|
pub fn check_type(t : Type_) -> Unit {
  check_func_type(t.it, t.at)
}

// Functions & Constants
// Conventions:
//   c : context
//   m : module_
//   f : func
//   e : instr
//   v : value
//   t : value_type
//   s : func_type
//   x : variable

///|
pub fn check_func(c : Context, f : Func) -> Unit raise {
  let { ftype, locals, body } = f.it
  let FuncType(ts1, ts2) = type_(c, ftype)
  let c_prime = { ..c, locals: ts1 + locals, results: ts2, labels: [ts2] }
  check_block(c_prime, body, FuncType([], ts2), f.at)
}

///|
pub fn is_const(c : Context, e : Instr) -> Bool raise {
  match e.it {
    RefNull(_) | RefFunc(_) | Const(_) | VecConst(_) => true
    GlobalGet(x) => {
      let { value_type: _, mutability } = global(c, x)
      mutability is Immutable
    }
    _ => false
  }
}

///|
pub fn check_const(c : Context, cons : Const, t : ValueType) -> Unit raise {
  if not(cons.it[:].any(instr => is_const(c, instr))) {
    fail("constant expression required")
  }
  check_block(c, cons.it, FuncType([], [t]), cons.at)
}

// Tables, Memories, & Globals

///|
pub fn check_table(c : Context, tab : Table) -> Unit raise {
  let { ttype } = tab.it
  check_table_type(ttype, tab.at)
}

///|
pub fn check_memory(c : Context, mem : Memory) -> Unit raise {
  let { mtype } = mem.it
  check_memory_type(mtype, mem.at)
}

///|
pub fn check_elem_mode(
  c : Context,
  t : RefType,
  mode : SegmentMode,
) -> Unit raise {
  match mode.it {
    Passive => ()
    Active({ index, offset }) => {
      let { limits: _, ref_type: et } = table(c, index)
      if t != et {
        fail(
          "type mismatch: element segment's type " +
          string_of_ref_type(t) +
          " does not match table's element type " +
          string_of_ref_type(et),
        )
      }
      check_const(c, offset, NumType(I32Type))
    }
    Declarative => ()
  }
}

///|
pub fn check_elem(c : Context, seg : ElemSegment) -> Unit raise {
  let { etype, einit, emode } = seg.it
  einit[:].each(con => check_const(c, con, RefType(etype)))
  check_elem_mode(c, etype, emode)
}

///|
pub fn check_data_mode(c : Context, mode : SegmentMode) -> Unit raise {
  match mode.it {
    Passive => ()
    Active({ index, offset }) => {
      ignore(memory(c, index))
      check_const(c, offset, NumType(I32Type))
    }
    Declarative => abort("Declarative mode not allowed for data segments")
  }
}

///|
pub fn check_data(c : Context, seg : DataSegment) -> Unit raise {
  let { dinit, dmode } = seg.it
  check_data_mode(c, dmode)
}

///|
pub fn check_global(c : Context, glob : Global) -> Unit raise {
  let { gtype, ginit } = glob.it
  let { value_type: t, mutability: _ } = gtype
  check_const(c, ginit, t)
}

// Modules

///|
pub fn check_start(c : Context, start : Start) -> Unit raise {
  let { sfunc } = start.it
  if not(func(c, sfunc) is FuncType([], [])) {
    fail("start function must not have parameters or results")
  }
}

///|
pub fn check_import(im : Import, c : Context) -> Context raise {
  let { module_name, item_name, idesc } = im.it
  match idesc.it {
    FuncImport(x) => { ..c, funcs: [type_(c, x), ..c.funcs] }
    TableImport(tt) => {
      check_table_type(tt, idesc.at)
      { ..c, tables: [tt, ..c.tables] }
    }
    MemoryImport(mt) => {
      check_memory_type(mt, idesc.at)
      { ..c, memories: [mt, ..c.memories] }
    }
    GlobalImport(gt) => {
      check_global_type(gt, idesc.at)
      { ..c, globals: [gt, ..c.globals] }
    }
  }
}

///|
pub fn check_export(
  c : Context,
  set : Set[Array[Int]],
  ex : Export,
) -> Set[Array[Int]] raise {
  let { name, edesc } = ex.it
  match edesc.it {
    FuncExport(x) => ignore(func(c, x))
    TableExport(x) => ignore(table(c, x))
    MemoryExport(x) => ignore(memory(c, x))
    GlobalExport(x) => ignore(global(c, x))
  }
  if set.contains(name) {
    fail("duplicate export name")
  }
  set.add(name)
  set
}

///|
pub fn check_module(m : Module_) -> Unit raise {
  let {
    types,
    imports,
    tables,
    memories,
    globals,
    funcs,
    start,
    elems,
    datas,
    exports,
  } = m.it
  let c0 = imports.rev_fold(
    init={
      ..empty_context,
      refs: module_({ it: { ..m.it, funcs: [], start: None }, at: m.at }),
      types: types.map(ty => ty.it),
    },
    (context, elem) => check_import(elem, context),
  )
  let c1 = {
    ..c0,
    funcs: c0.funcs + funcs.map(f => type_(c0, f.it.ftype)),
    tables: c0.tables + tables.map(tab => tab.it.ttype),
    memories: c0.memories + memories.map(mem => mem.it.mtype),
    elems: elems.map(elem => elem.it.etype),
    datas: datas.map(_data => ()),
  }
  let c = { ..c1, globals: c1.globals + globals.map(g => g.it.gtype) }
  types.each(check_type)
  globals.each(check_global(c1, _))
  tables.each(check_table(c1, _))
  memories.each(check_memory(c1, _))
  elems.each(check_elem(c1, _))
  datas.each(check_data(c1, _))
  funcs.each(check_func(c, _))
  match start {
    Some(s) => check_start(c, s)
    None => ()
  }
  ignore(
    exports.fold(init=Set::new(), (set, elem) => check_export(c, set, elem)),
  )
  if c.memories.length() > 1 {
    fail("multiple memories are not allowed (yet)")
  }
}

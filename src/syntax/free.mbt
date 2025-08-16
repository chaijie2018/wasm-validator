///|
pub struct FreeVars {
  types : Set[Int]
  globals : Set[Int]
  tables : Set[Int]
  memories : Set[Int]
  funcs : Set[Int]
  elems : Set[Int]
  datas : Set[Int]
  locals : Set[Int]
  labels : Set[Int]
}

///|
pub fn FreeVars::union(self : FreeVars, s : FreeVars) -> FreeVars {
  {
    types: Set::union(self.types, s.types),
    globals: Set::union(self.globals, s.globals),
    tables: Set::union(self.tables, s.tables),
    memories: Set::union(self.memories, s.memories),
    funcs: Set::union(self.funcs, s.funcs),
    elems: Set::union(self.elems, s.elems),
    datas: Set::union(self.datas, s.datas),
    locals: Set::union(self.locals, s.locals),
    labels: Set::union(self.labels, s.labels),
  }
}

///|
impl Add for FreeVars with op_add(self : FreeVars, other : FreeVars) -> FreeVars {
  self.union(other)
}

///|
pub let empty_free_vars : FreeVars = {
  types: Set::new(),
  globals: Set::new(),
  tables: Set::new(),
  memories: Set::new(),
  funcs: Set::new(),
  elems: Set::new(),
  datas: Set::new(),
  locals: Set::new(),
  labels: Set::new(),
}

///|
fn types(s : Set[Int]) -> FreeVars {
  let empty_set = empty_free_vars
  { ..empty_set, types: s }
}

///|
fn free_globals(s : Set[Int]) -> FreeVars {
  let empty_set = empty_free_vars
  { ..empty_set, globals: s }
}

///|
fn free_tables(s : Set[Int]) -> FreeVars {
  let empty_set = empty_free_vars
  { ..empty_set, tables: s }
}

///|
fn free_memories(s : Set[Int]) -> FreeVars {
  let empty_set = empty_free_vars
  { ..empty_set, memories: s }
}

///|
fn free_funcs(s : Set[Int]) -> FreeVars {
  let empty_set = empty_free_vars
  { ..empty_set, funcs: s }
}

///|
fn elems(s : Set[Int]) -> FreeVars {
  let empty_set = empty_free_vars
  { ..empty_set, elems: s }
}

///|
fn datas(s : Set[Int]) -> FreeVars {
  let empty_set = empty_free_vars
  { ..empty_set, datas: s }
}

///|
fn locals(s : Set[Int]) -> FreeVars {
  let empty_set = empty_free_vars
  { ..empty_set, locals: s }
}

///|
fn labels(s : Set[Int]) -> FreeVars {
  let empty_set = empty_free_vars
  { ..empty_set, labels: s }
}

///|
fn var(x : Var) -> Set[Int] {
  Set::from_array([x.it])
}

///|
fn zero() -> Set[Int] {
  Set::from_array([0])
}

///|
fn shift(s : Set[Int]) -> Set[Int] {
  s.remove(0)
  let mapped_array = s.to_array().map(x => x - 1)
  Set::from_array(mapped_array)
}

///|
fn[T] list(free_fn : (T) -> FreeVars, xs : Array[T]) -> FreeVars {
  xs.fold(init=empty_free_vars, fn(acc, x) { acc + free_fn(x) })
}

///|
fn[T] opt(free_fn : (T) -> FreeVars, xo : T?) -> FreeVars {
  match xo {
    Some(x) => free_fn(x)
    None => empty_free_vars
  }
}

///|
fn block_type(bt : BlockType) -> FreeVars {
  match bt {
    VarBlockType(x) => types(var(x))
    ValBlockType(_) => empty_free_vars
  }
}

///|
fn instr(e : Instr) -> FreeVars {
  match e.it {
    Unreachable => empty_free_vars
    Nop => empty_free_vars
    Drop => empty_free_vars
    Select(_) => empty_free_vars
    RefNull(_) => empty_free_vars
    RefIsNull => empty_free_vars
    RefFunc(x) => free_funcs(var(x))
    Const(_) => empty_free_vars
    Test(_) => empty_free_vars
    Compare(_) => empty_free_vars
    Unary(_) => empty_free_vars
    Binary(_) => empty_free_vars
    Convert(_) => empty_free_vars
    Block(bt, es) => block_type(bt) + block(es)
    Loop(bt, es) => block_type(bt) + block(es)
    If(bt, es1, es2) => block_type(bt) + block(es1) + block(es2)
    Br(x) => labels(var(x))
    BrIf(x) => labels(var(x))
    BrTable(xs, x) => {
      let all_labels = [x, ..xs]
      list(fn(x) { labels(var(x)) }, all_labels)
    }
    Return => empty_free_vars
    Call(x) => free_funcs(var(x))
    CallIndirect(x, y) => free_tables(var(x)) + types(var(y))
    LocalGet(x) => locals(var(x))
    LocalSet(x) => locals(var(x))
    LocalTee(x) => locals(var(x))
    GlobalGet(x) => free_globals(var(x))
    GlobalSet(x) => free_globals(var(x))
    TableGet(x) => free_tables(var(x))
    TableSet(x) => free_tables(var(x))
    TableSize(x) => free_tables(var(x))
    TableGrow(x) => free_tables(var(x))
    TableFill(x) => free_tables(var(x))
    TableCopy(x, y) => free_tables(var(x)) + free_tables(var(y))
    TableInit(x, y) => free_tables(var(x)) + elems(var(y))
    ElemDrop(x) => elems(var(x))
    Load(_) => free_memories(zero())
    Store(_) => free_memories(zero())
    VecLoad(_) => free_memories(zero())
    VecStore(_) => free_memories(zero())
    VecLoadLane(_) => free_memories(zero())
    VecStoreLane(_) => free_memories(zero())
    MemorySize => free_memories(zero())
    MemoryGrow => free_memories(zero())
    MemoryCopy => free_memories(zero())
    MemoryFill => free_memories(zero())
    VecConst(_) => free_memories(zero())
    VecTest(_) => free_memories(zero())
    VecUnary(_) => free_memories(zero())
    VecBinary(_) => free_memories(zero())
    VecCompare(_) => free_memories(zero())
    VecConvert(_) => free_memories(zero())
    VecShift(_) => free_memories(zero())
    VecBitmask(_) => free_memories(zero())
    VecTestBits(_) => free_memories(zero())
    VecUnaryBits(_) => free_memories(zero())
    VecBinaryBits(_) => free_memories(zero())
    VecTernaryBits(_) => free_memories(zero())
    VecSplat(_) => free_memories(zero())
    VecExtract(_) => free_memories(zero())
    VecReplace(_) => free_memories(zero())
    MemoryInit(x) => free_memories(zero()) + datas(var(x))
    DataDrop(x) => datas(var(x))
  }
}

///|
fn block(es : Array[Instr]) -> FreeVars {
  let free = list(instr, es)
  { ..free, labels: shift(free.labels) }
}

///|
fn const_expr(c : Const) -> FreeVars {
  block(c.it)
}

///|
fn free_global(g : Global) -> FreeVars {
  const_expr(g.it.ginit)
}

///|
fn free_func(f : Func) -> FreeVars {
  let block_free = block(f.it.body)
  { ..block_free, locals: Set::new() }
}

///|
fn free_table(t : Table) -> FreeVars {
  empty_free_vars
}

///|
fn free_memory(m : Memory) -> FreeVars {
  empty_free_vars
}

///|
fn segment_mode(free_fn : (Set[Int]) -> FreeVars, m : SegmentMode) -> FreeVars {
  match m.it {
    Passive => empty_free_vars
    Active({ index, offset }) =>
      free_fn(Set::from_array([index.it])) + const_expr(offset)
    Declarative => empty_free_vars
  }
}

///|
fn free_elem(s : ElemSegment) -> FreeVars {
  list(const_expr, s.it.einit) + segment_mode(free_tables, s.it.emode)
}

///|
fn free_data(s : DataSegment) -> FreeVars {
  segment_mode(free_memories, s.it.dmode)
}

///|
fn free_type_(t : Type_) -> FreeVars {
  empty_free_vars
}

///|
fn export_desc(d : ExportDesc) -> FreeVars {
  match d.it {
    FuncExport(x) => free_funcs(var(x))
    TableExport(x) => free_tables(var(x))
    MemoryExport(x) => free_memories(var(x))
    GlobalExport(x) => free_globals(var(x))
  }
}

///|
fn free_export(e : Export) -> FreeVars {
  export_desc(e.it.edesc)
}

///|
pub fn import_desc(d : ImportDesc) -> FreeVars {
  match d.it {
    FuncImport(x) => types(var(x))
    TableImport(_) => empty_free_vars
    MemoryImport(_) => empty_free_vars
    GlobalImport(_) => empty_free_vars
  }
}

///|
pub fn free_import(i : Import) -> FreeVars {
  import_desc(i.it.idesc)
}

///|
pub fn free_start(s : Start) -> FreeVars {
  free_funcs(var(s.it.sfunc))
}

///|
pub fn module_(m : Module_) -> FreeVars {
  list(free_type_, m.it.types)
  .union(list(free_global, m.it.globals))
  .union(list(free_table, m.it.tables))
  .union(list(free_memory, m.it.memories))
  .union(list(free_func, m.it.funcs))
  .union(opt(free_start, m.it.start))
  .union(list(free_elem, m.it.elems))
  .union(list(free_data, m.it.datas))
  .union(list(free_import, m.it.imports))
  .union(list(free_export, m.it.exports))
}

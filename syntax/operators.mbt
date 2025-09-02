///|
pub fn i32_const(n : Var) -> InstrType {
  Const(I32(n))
}

///|
pub fn i64_const(n : Int64) -> InstrType {
  Const(I64(n))
}

///|
pub fn f32_const(n : Float) -> InstrType {
  Const(F32(n))
}

///|
pub fn f64_const(n : Double) -> InstrType {
  Const(F64(n))
}

///|
pub fn v128_const(n : Bytes) -> InstrType {
  VecConst(V128(n))
}

///|
pub fn ref_null(t : RefType) -> InstrType {
  RefNull(t)
}

///|
pub fn ref_func(x : Var) -> InstrType {
  RefFunc(x)
}

// Control flow instructions

///|
pub fn select(t : @list.List[ValueType]?) -> InstrType {
  Select(t)
}

///|
pub fn block2(bt : BlockType, es : @list.List[InstrType]) -> InstrType {
  Block(bt, es)
}

///|
pub fn loop2(bt : BlockType, es : @list.List[InstrType]) -> InstrType {
  Loop(bt, es)
}

///|
pub fn if2(
  bt : BlockType,
  es1 : @list.List[InstrType],
  es2 : @list.List[InstrType],
) -> InstrType {
  If(bt, es1, es2)
}

///|
pub fn br(x : Var) -> InstrType {
  Br(x)
}

///|
pub fn br_if(x : Var) -> InstrType {
  BrIf(x)
}

///|
pub fn br_table(xs : @list.List[Var], x : Var) -> InstrType {
  BrTable(xs, x)
}

///|
pub let return_ : InstrType = Return

///|
pub fn call(x : Var) -> InstrType {
  Call(x)
}

///|
pub fn call_indirect(x : Var, y : Var) -> InstrType {
  CallIndirect(x, y)
}

// Local variable instructions

///|
pub fn local_get(x : Var) -> InstrType {
  LocalGet(x)
}

///|
pub fn local_set(x : Var) -> InstrType {
  LocalSet(x)
}

///|
pub fn local_tee(x : Var) -> InstrType {
  LocalTee(x)
}

///|
pub fn global_get(x : Var) -> InstrType {
  GlobalGet(x)
}

///|
pub fn global_set(x : Var) -> InstrType {
  GlobalSet(x)
}

// Table operation instructions

///|
pub fn table_get(x : Var) -> InstrType {
  TableGet(x)
}

///|
pub fn table_set(x : Var) -> InstrType {
  TableSet(x)
}

///|
pub fn table_size(x : Var) -> InstrType {
  TableSize(x)
}

///|
pub fn table_grow(x : Var) -> InstrType {
  TableGrow(x)
}

///|
pub fn table_fill(x : Var) -> InstrType {
  TableFill(x)
}

///|
pub fn table_copy(x : Var, y : Var) -> InstrType {
  TableCopy(x, y)
}

///|
pub fn table_init(x : Var, y : Var) -> InstrType {
  TableInit(x, y)
}

///|
pub fn elem_drop(x : Var) -> InstrType {
  ElemDrop(x)
}

// Memory load instructions

///|
pub fn i32_load(align : Int, offset : Int) -> InstrType {
  Load({ ty: I32Type, align, offset, pack: None })
}

///|
pub fn i64_load(align : Int, offset : Int) -> InstrType {
  Load({ ty: I64Type, align, offset, pack: None })
}

///|
pub fn f32_load(align : Int, offset : Int) -> InstrType {
  Load({ ty: F32Type, align, offset, pack: None })
}

///|
pub fn f64_load(align : Int, offset : Int) -> InstrType {
  Load({ ty: F64Type, align, offset, pack: None })
}

///|
pub fn i32_load8_s(align : Int, offset : Int) -> InstrType {
  Load({ ty: I32Type, align, offset, pack: Some((Pack8, SX)) })
}

///|
pub fn i32_load8_u(align : Int, offset : Int) -> InstrType {
  Load({ ty: I32Type, align, offset, pack: Some((Pack8, ZX)) })
}

///|
pub fn i32_load16_s(align : Int, offset : Int) -> InstrType {
  Load({ ty: I32Type, align, offset, pack: Some((Pack16, SX)) })
}

///|
pub fn i32_load16_u(align : Int, offset : Int) -> InstrType {
  Load({ ty: I32Type, align, offset, pack: Some((Pack16, ZX)) })
}

///|
pub fn i64_load8_s(align : Int, offset : Int) -> InstrType {
  Load({ ty: I64Type, align, offset, pack: Some((Pack8, SX)) })
}

///|
pub fn i64_load8_u(align : Int, offset : Int) -> InstrType {
  Load({ ty: I64Type, align, offset, pack: Some((Pack8, ZX)) })
}

///|
pub fn i64_load16_s(align : Int, offset : Int) -> InstrType {
  Load({ ty: I64Type, align, offset, pack: Some((Pack16, SX)) })
}

///|
pub fn i64_load16_u(align : Int, offset : Int) -> InstrType {
  Load({ ty: I64Type, align, offset, pack: Some((Pack16, ZX)) })
}

///|
pub fn i64_load32_s(align : Int, offset : Int) -> InstrType {
  Load({ ty: I64Type, align, offset, pack: Some((Pack32, SX)) })
}

///|
pub fn i64_load32_u(align : Int, offset : Int) -> InstrType {
  Load({ ty: I64Type, align, offset, pack: Some((Pack32, ZX)) })
}

// Memory store instructions

///|
pub fn i32_store(align : Int, offset : Int) -> InstrType {
  Store({ ty: I32Type, align, offset, pack: None })
}

///|
pub fn i64_store(align : Int, offset : Int) -> InstrType {
  Store({ ty: I64Type, align, offset, pack: None })
}

///|
pub fn f32_store(align : Int, offset : Int) -> InstrType {
  Store({ ty: F32Type, align, offset, pack: None })
}

///|
pub fn f64_store(align : Int, offset : Int) -> InstrType {
  Store({ ty: F64Type, align, offset, pack: None })
}

///|
pub fn i32_store8(align : Int, offset : Int) -> InstrType {
  Store({ ty: I32Type, align, offset, pack: Some(Pack8) })
}

///|
pub fn i32_store16(align : Int, offset : Int) -> InstrType {
  Store({ ty: I32Type, align, offset, pack: Some(Pack16) })
}

///|
pub fn i64_store8(align : Int, offset : Int) -> InstrType {
  Store({ ty: I64Type, align, offset, pack: Some(Pack8) })
}

///|
pub fn i64_store16(align : Int, offset : Int) -> InstrType {
  Store({ ty: I64Type, align, offset, pack: Some(Pack16) })
}

///|
pub fn i64_store32(align : Int, offset : Int) -> InstrType {
  Store({ ty: I64Type, align, offset, pack: Some(Pack32) })
}

// Memory control instructions

///|
pub let memory_size : InstrType = MemorySize

///|
pub let memory_grow : InstrType = MemoryGrow

///|
pub let memory_fill : InstrType = MemoryFill

///|
pub let memory_copy : InstrType = MemoryCopy

///|
pub fn memory_init(x : Var) -> InstrType {
  MemoryInit(x)
}

///|
pub fn data_drop(x : Var) -> InstrType {
  DataDrop(x)
}

///|
pub let ref_is_null : InstrType = RefIsNull

// Integer unary operations

///|
pub let i32_clz : InstrType = Unary(I32(Clz))

///|
pub let i32_ctz : InstrType = Unary(I32(Ctz))

///|
pub let i32_popcnt : InstrType = Unary(I32(Popcnt))

///|
pub let i64_clz : InstrType = Unary(I64(Clz))

///|
pub let i64_ctz : InstrType = Unary(I64(Ctz))

///|
pub let i64_popcnt : InstrType = Unary(I64(Popcnt))

// Float unary operations

///|
pub let f32_neg : InstrType = Unary(F32(Neg))

///|
pub let f32_abs : InstrType = Unary(F32(Abs))

///|
pub let f32_sqrt : InstrType = Unary(F32(Sqrt))

///|
pub let f32_ceil : InstrType = Unary(F32(Ceil))

///|
pub let f32_floor : InstrType = Unary(F32(Floor))

///|
pub let f32_trunc : InstrType = Unary(F32(Trunc))

///|
pub let f32_nearest : InstrType = Unary(F32(Nearest))

///|
pub let f64_neg : InstrType = Unary(F64(Neg))

///|
pub let f64_abs : InstrType = Unary(F64(Abs))

///|
pub let f64_sqrt : InstrType = Unary(F64(Sqrt))

///|
pub let f64_ceil : InstrType = Unary(F64(Ceil))

///|
pub let f64_floor : InstrType = Unary(F64(Floor))

///|
pub let f64_trunc : InstrType = Unary(F64(Trunc))

///|
pub let f64_nearest : InstrType = Unary(F64(Nearest))

// Integer binary operations

///|
pub let i32_add : InstrType = Binary(I32(Add))

///|
pub let i32_sub : InstrType = Binary(I32(Sub))

///|
pub let i32_mul : InstrType = Binary(I32(Mul))

///|
pub let i32_div_s : InstrType = Binary(I32(DivS))

///|
pub let i32_div_u : InstrType = Binary(I32(DivU))

///|
pub let i32_rem_s : InstrType = Binary(I32(RemS))

///|
pub let i32_rem_u : InstrType = Binary(I32(RemU))

///|
pub let i32_and : InstrType = Binary(I32(And))

///|
pub let i32_or : InstrType = Binary(I32(Or))

///|
pub let i32_xor : InstrType = Binary(I32(Xor))

///|
pub let i32_shl : InstrType = Binary(I32(Shl))

///|
pub let i32_shr_s : InstrType = Binary(I32(ShrS))

///|
pub let i32_shr_u : InstrType = Binary(I32(ShrU))

///|
pub let i32_rotl : InstrType = Binary(I32(Rotl))

///|
pub let i32_rotr : InstrType = Binary(I32(Rotr))

///|
pub let i64_add : InstrType = Binary(I64(Add))

///|
pub let i64_sub : InstrType = Binary(I64(Sub))

///|
pub let i64_mul : InstrType = Binary(I64(Mul))

///|
pub let i64_div_s : InstrType = Binary(I64(DivS))

///|
pub let i64_div_u : InstrType = Binary(I64(DivU))

///|
pub let i64_rem_s : InstrType = Binary(I64(RemS))

///|
pub let i64_rem_u : InstrType = Binary(I64(RemU))

///|
pub let i64_and : InstrType = Binary(I64(And))

///|
pub let i64_or : InstrType = Binary(I64(Or))

///|
pub let i64_xor : InstrType = Binary(I64(Xor))

///|
pub let i64_shl : InstrType = Binary(I64(Shl))

///|
pub let i64_shr_s : InstrType = Binary(I64(ShrS))

///|
pub let i64_shr_u : InstrType = Binary(I64(ShrU))

///|
pub let i64_rotl : InstrType = Binary(I64(Rotl))

///|
pub let i64_rotr : InstrType = Binary(I64(Rotr))

// Float binary operations

///|
pub let f32_add : InstrType = Binary(F32(Add))

///|
pub let f32_sub : InstrType = Binary(F32(Sub))

///|
pub let f32_mul : InstrType = Binary(F32(Mul))

///|
pub let f32_div : InstrType = Binary(F32(Div))

///|
pub let f32_min : InstrType = Binary(F32(Min))

///|
pub let f32_max : InstrType = Binary(F32(Max))

///|
pub let f32_copysign : InstrType = Binary(F32(CopySign))

///|
pub let f64_add : InstrType = Binary(F64(Add))

///|
pub let f64_sub : InstrType = Binary(F64(Sub))

///|
pub let f64_mul : InstrType = Binary(F64(Mul))

///|
pub let f64_div : InstrType = Binary(F64(Div))

///|
pub let f64_min : InstrType = Binary(F64(Min))

///|
pub let f64_max : InstrType = Binary(F64(Max))

///|
pub let f64_copysign : InstrType = Binary(F64(CopySign))

// Test operations

///|
pub let i32_eqz : InstrType = Test(I32(Eqz))

///|
pub let i64_eqz : InstrType = Test(I64(Eqz))

// Comparison operations

///|
pub let i32_eq : InstrType = Compare(I32(Eq))

///|
pub let i32_ne : InstrType = Compare(I32(Ne))

///|
pub let i32_lt_s : InstrType = Compare(I32(LtS))

///|
pub let i32_lt_u : InstrType = Compare(I32(LtU))

///|
pub let i32_le_s : InstrType = Compare(I32(LeS))

///|
pub let i32_le_u : InstrType = Compare(I32(LeU))

///|
pub let i32_gt_s : InstrType = Compare(I32(GtS))

///|
pub let i32_gt_u : InstrType = Compare(I32(GtU))

///|
pub let i32_ge_s : InstrType = Compare(I32(GeS))

///|
pub let i32_ge_u : InstrType = Compare(I32(GeU))

///|
pub let i64_eq : InstrType = Compare(I64(Eq))

///|
pub let i64_ne : InstrType = Compare(I64(Ne))

///|
pub let i64_lt_s : InstrType = Compare(I64(LtS))

///|
pub let i64_lt_u : InstrType = Compare(I64(LtU))

///|
pub let i64_le_s : InstrType = Compare(I64(LeS))

///|
pub let i64_le_u : InstrType = Compare(I64(LeU))

///|
pub let i64_gt_s : InstrType = Compare(I64(GtS))

///|
pub let i64_gt_u : InstrType = Compare(I64(GtU))

///|
pub let i64_ge_s : InstrType = Compare(I64(GeS))

///|
pub let i64_ge_u : InstrType = Compare(I64(GeU))

///|
pub let f32_eq : InstrType = Compare(F32(Eq))

///|
pub let f32_ne : InstrType = Compare(F32(Ne))

///|
pub let f32_lt : InstrType = Compare(F32(Lt))

///|
pub let f32_le : InstrType = Compare(F32(Le))

///|
pub let f32_gt : InstrType = Compare(F32(Gt))

///|
pub let f32_ge : InstrType = Compare(F32(Ge))

///|
pub let f64_eq : InstrType = Compare(F64(Eq))

///|
pub let f64_ne : InstrType = Compare(F64(Ne))

///|
pub let f64_lt : InstrType = Compare(F64(Lt))

///|
pub let f64_le : InstrType = Compare(F64(Le))

///|
pub let f64_gt : InstrType = Compare(F64(Gt))

///|
pub let f64_ge : InstrType = Compare(F64(Ge))

// Sign extension operations

///|
pub let i32_extend8_s : InstrType = Unary(I32(ExtendS(Pack8)))

///|
pub let i32_extend16_s : InstrType = Unary(I32(ExtendS(Pack16)))

///|
pub let i64_extend8_s : InstrType = Unary(I64(ExtendS(Pack8)))

///|
pub let i64_extend16_s : InstrType = Unary(I64(ExtendS(Pack16)))

///|
pub let i64_extend32_s : InstrType = Unary(I64(ExtendS(Pack32)))

// Conversion operations

///|
pub let i32_wrap_i64 : InstrType = Convert(I32(WrapI64))

///|
pub let i32_trunc_f32_s : InstrType = Convert(I32(TruncSF32))

///|
pub let i32_trunc_f32_u : InstrType = Convert(I32(TruncUF32))

///|
pub let i32_trunc_f64_s : InstrType = Convert(I32(TruncSF64))

///|
pub let i32_trunc_f64_u : InstrType = Convert(I32(TruncUF64))

///|
pub let i32_trunc_sat_f32_s : InstrType = Convert(I32(TruncSatSF32))

///|
pub let i32_trunc_sat_f32_u : InstrType = Convert(I32(TruncSatUF32))

///|
pub let i32_trunc_sat_f64_s : InstrType = Convert(I32(TruncSatSF64))

///|
pub let i32_trunc_sat_f64_u : InstrType = Convert(I32(TruncSatUF64))

///|
pub let i64_extend_i32_s : InstrType = Convert(I64(ExtendSI32))

///|
pub let i64_extend_i32_u : InstrType = Convert(I64(ExtendUI32))

///|
pub let i64_trunc_f32_s : InstrType = Convert(I64(TruncSF32))

///|
pub let i64_trunc_f32_u : InstrType = Convert(I64(TruncUF32))

///|
pub let i64_trunc_f64_s : InstrType = Convert(I64(TruncSF64))

///|
pub let i64_trunc_f64_u : InstrType = Convert(I64(TruncUF64))

///|
pub let f32_convert_i32_s : InstrType = Convert(F32(ConvertSI32))

///|
pub let f32_convert_i32_u : InstrType = Convert(F32(ConvertUI32))

///|
pub let f32_convert_i64_s : InstrType = Convert(F32(ConvertSI64))

///|
pub let f32_convert_i64_u : InstrType = Convert(F32(ConvertUI64))

///|
pub let i64_trunc_sat_f32_s : InstrType = Convert(I64(TruncSatSF32))

///|
pub let i64_trunc_sat_f32_u : InstrType = Convert(I64(TruncSatUF32))

///|
pub let i64_trunc_sat_f64_s : InstrType = Convert(I64(TruncSatSF64))

///|
pub let i64_trunc_sat_f64_u : InstrType = Convert(I64(TruncSatUF64))

///|
pub let f32_demote_f64 : InstrType = Convert(F32(DemoteF64))

///|
pub let f64_convert_i32_s : InstrType = Convert(F64(ConvertSI32))

///|
pub let f64_convert_i32_u : InstrType = Convert(F64(ConvertUI32))

///|
pub let f64_convert_i64_s : InstrType = Convert(F64(ConvertSI64))

///|
pub let f64_convert_i64_u : InstrType = Convert(F64(ConvertUI64))

///|
pub let f64_promote_f32 : InstrType = Convert(F64(PromoteF32))

///|
pub let i32_reinterpret_f32 : InstrType = Convert(I32(ReinterpretFloat))

///|
pub let i64_reinterpret_f64 : InstrType = Convert(I64(ReinterpretFloat))

///|
pub let f32_reinterpret_i32 : InstrType = Convert(F32(ReinterpretInt))

///|
pub let f64_reinterpret_i64 : InstrType = Convert(F64(ReinterpretInt))

// Vector load operations

///|
pub fn v128_load(align : Int, offset : Int) -> InstrType {
  VecLoad({ ty: V128Type, align, offset, pack: None })
}

///|
pub fn v128_load8x8_s(align : Int, offset : Int) -> InstrType {
  VecLoad({
    ty: V128Type,
    align,
    offset,
    pack: Some((Pack64, ExtLane(Pack8x8, SX))),
  })
}

///|
pub fn v128_load8x8_u(align : Int, offset : Int) -> InstrType {
  VecLoad({
    ty: V128Type,
    align,
    offset,
    pack: Some((Pack64, ExtLane(Pack8x8, ZX))),
  })
}

///|
pub fn v128_load16x4_s(align : Int, offset : Int) -> InstrType {
  VecLoad({
    ty: V128Type,
    align,
    offset,
    pack: Some((Pack64, ExtLane(Pack16x4, SX))),
  })
}

///|
pub fn v128_load16x4_u(align : Int, offset : Int) -> InstrType {
  VecLoad({
    ty: V128Type,
    align,
    offset,
    pack: Some((Pack64, ExtLane(Pack16x4, ZX))),
  })
}

///|
pub fn v128_load32x2_s(align : Int, offset : Int) -> InstrType {
  VecLoad({
    ty: V128Type,
    align,
    offset,
    pack: Some((Pack64, ExtLane(Pack32x2, SX))),
  })
}

///|
pub fn v128_load32x2_u(align : Int, offset : Int) -> InstrType {
  VecLoad({
    ty: V128Type,
    align,
    offset,
    pack: Some((Pack64, ExtLane(Pack32x2, ZX))),
  })
}

///|
pub fn v128_load8_splat(align : Int, offset : Int) -> InstrType {
  VecLoad({ ty: V128Type, align, offset, pack: Some((Pack8, ExtSplat)) })
}

///|
pub fn v128_load16_splat(align : Int, offset : Int) -> InstrType {
  VecLoad({ ty: V128Type, align, offset, pack: Some((Pack16, ExtSplat)) })
}

///|
pub fn v128_load32_splat(align : Int, offset : Int) -> InstrType {
  VecLoad({ ty: V128Type, align, offset, pack: Some((Pack32, ExtSplat)) })
}

///|
pub fn v128_load64_splat(align : Int, offset : Int) -> InstrType {
  VecLoad({ ty: V128Type, align, offset, pack: Some((Pack64, ExtSplat)) })
}

///|
pub fn v128_load32_zero(align : Int, offset : Int) -> InstrType {
  VecLoad({ ty: V128Type, align, offset, pack: Some((Pack32, ExtZero)) })
}

///|
pub fn v128_load64_zero(align : Int, offset : Int) -> InstrType {
  VecLoad({ ty: V128Type, align, offset, pack: Some((Pack64, ExtZero)) })
}

///|
pub fn v128_store(align : Int, offset : Int) -> InstrType {
  VecStore({ ty: V128Type, align, offset, pack: () })
}

// Vector lane operations

///|
pub fn v128_load8_lane(align : Int, offset : Int, i : Int) -> InstrType {
  VecLoadLane(({ ty: V128Type, align, offset, pack: Pack8 }, i))
}

///|
pub fn v128_load16_lane(align : Int, offset : Int, i : Int) -> InstrType {
  VecLoadLane(({ ty: V128Type, align, offset, pack: Pack16 }, i))
}

///|
pub fn v128_load32_lane(align : Int, offset : Int, i : Int) -> InstrType {
  VecLoadLane(({ ty: V128Type, align, offset, pack: Pack32 }, i))
}

///|
pub fn v128_load64_lane(align : Int, offset : Int, i : Int) -> InstrType {
  VecLoadLane(({ ty: V128Type, align, offset, pack: Pack64 }, i))
}

///|
pub fn v128_store8_lane(align : Int, offset : Int, i : Int) -> InstrType {
  VecStoreLane(({ ty: V128Type, align, offset, pack: Pack8 }, i))
}

///|
pub fn v128_store16_lane(align : Int, offset : Int, i : Int) -> InstrType {
  VecStoreLane(({ ty: V128Type, align, offset, pack: Pack16 }, i))
}

///|
pub fn v128_store32_lane(align : Int, offset : Int, i : Int) -> InstrType {
  VecStoreLane(({ ty: V128Type, align, offset, pack: Pack32 }, i))
}

///|
pub fn v128_store64_lane(align : Int, offset : Int, i : Int) -> InstrType {
  VecStoreLane(({ ty: V128Type, align, offset, pack: Pack64 }, i))
}

// Vector bit operations

///|
pub let v128_not : InstrType = VecUnaryBits(V128(Not))

///|
pub let v128_and : InstrType = VecBinaryBits(V128(And))

///|
pub let v128_andnot : InstrType = VecBinaryBits(V128(AndNot))

///|
pub let v128_or : InstrType = VecBinaryBits(V128(Or))

///|
pub let v128_xor : InstrType = VecBinaryBits(V128(Xor))

///|
pub let v128_bitselect : InstrType = VecTernaryBits(V128(Bitselect))

///|
pub let v128_any_true : InstrType = VecTestBits(V128(AnyTrue))

// i8x16 operations

///|
pub let i8x16_swizzle : InstrType = VecBinary(V128(I8x16(Swizzle)))

///|
pub fn i8x16_shuffle(arr : Array[Int]) -> InstrType {
  VecBinary(V128(I8x16(Shuffle(arr))))
}

///|
pub let i8x16_splat : InstrType = VecSplat(V128(I8x16(Splat)))

///|
pub fn i8x16_extract_lane_s(i : Int) -> InstrType {
  VecExtract(V128(I8x16(Extract(i, SX))))
}

///|
pub fn i8x16_extract_lane_u(i : Int) -> InstrType {
  VecExtract(V128(I8x16(Extract(i, ZX))))
}

///|
pub fn i8x16_replace_lane(i : Int) -> InstrType {
  VecReplace(V128(I8x16(Replace(i))))
}

///|
pub let i8x16_eq : InstrType = VecCompare(V128(I8x16(Eq)))

///|
pub let i8x16_ne : InstrType = VecCompare(V128(I8x16(Ne)))

///|
pub let i8x16_lt_s : InstrType = VecCompare(V128(I8x16(LtS)))

///|
pub let i8x16_lt_u : InstrType = VecCompare(V128(I8x16(LtU)))

///|
pub let i8x16_le_s : InstrType = VecCompare(V128(I8x16(LeS)))

///|
pub let i8x16_le_u : InstrType = VecCompare(V128(I8x16(LeU)))

///|
pub let i8x16_gt_s : InstrType = VecCompare(V128(I8x16(GtS)))

///|
pub let i8x16_gt_u : InstrType = VecCompare(V128(I8x16(GtU)))

///|
pub let i8x16_ge_s : InstrType = VecCompare(V128(I8x16(GeS)))

///|
pub let i8x16_ge_u : InstrType = VecCompare(V128(I8x16(GeU)))

///|
pub let i8x16_neg : InstrType = VecUnary(V128(I8x16(Neg)))

///|
pub let i8x16_bitmask : InstrType = VecBitmask(V128(I8x16(Bitmask)))

///|
pub let i8x16_all_true : InstrType = VecTest(V128(I8x16(AllTrue)))

///|
pub let i8x16_narrow_i16x8_s : InstrType = VecBinary(V128(I8x16(NarrowS)))

///|
pub let i8x16_narrow_i16x8_u : InstrType = VecBinary(V128(I8x16(NarrowU)))

///|
pub let i16x8_extend_low_i8x16_s : InstrType = VecConvert(
  V128(I16x8(ExtendLowS)),
)

///|
pub let i16x8_extend_high_i8x16_s : InstrType = VecConvert(
  V128(I16x8(ExtendHighS)),
)

///|
pub let i16x8_extend_low_i8x16_u : InstrType = VecConvert(
  V128(I16x8(ExtendLowU)),
)

///|
pub let i16x8_extend_high_i8x16_u : InstrType = VecConvert(
  V128(I16x8(ExtendHighU)),
)

///|
pub let i8x16_shl : InstrType = VecShift(V128(I8x16(Shl)))

///|
pub let i8x16_shr_s : InstrType = VecShift(V128(I8x16(ShrS)))

///|
pub let i8x16_shr_u : InstrType = VecShift(V128(I8x16(ShrU)))

///|
pub let i8x16_add : InstrType = VecBinary(V128(I8x16(Add)))

///|
pub let i8x16_add_sat_s : InstrType = VecBinary(V128(I8x16(AddSatS)))

///|
pub let i8x16_add_sat_u : InstrType = VecBinary(V128(I8x16(AddSatU)))

///|
pub let i8x16_sub : InstrType = VecBinary(V128(I8x16(Sub)))

///|
pub let i8x16_sub_sat_s : InstrType = VecBinary(V128(I8x16(SubSatS)))

///|
pub let i8x16_sub_sat_u : InstrType = VecBinary(V128(I8x16(SubSatU)))

///|
pub let i8x16_abs : InstrType = VecUnary(V128(I8x16(Abs)))

///|
pub let i8x16_popcnt : InstrType = VecUnary(V128(I8x16(Popcnt)))

///|
pub let i8x16_min_s : InstrType = VecBinary(V128(I8x16(MinS)))

///|
pub let i8x16_min_u : InstrType = VecBinary(V128(I8x16(MinU)))

///|
pub let i8x16_max_s : InstrType = VecBinary(V128(I8x16(MaxS)))

///|
pub let i8x16_max_u : InstrType = VecBinary(V128(I8x16(MaxU)))

///|
pub let i8x16_avgr_u : InstrType = VecBinary(V128(I8x16(AvgrU)))

// i16x8 operations

///|
pub let i16x8_splat : InstrType = VecSplat(V128(I16x8(Splat)))

///|
pub fn i16x8_extract_lane_s(i : Int) -> InstrType {
  VecExtract(V128(I16x8(Extract(i, SX))))
}

///|
pub fn i16x8_extract_lane_u(i : Int) -> InstrType {
  VecExtract(V128(I16x8(Extract(i, ZX))))
}

///|
pub fn i16x8_replace_lane(i : Int) -> InstrType {
  VecReplace(V128(I16x8(Replace(i))))
}

///|
pub let i16x8_eq : InstrType = VecCompare(V128(I16x8(Eq)))

///|
pub let i16x8_ne : InstrType = VecCompare(V128(I16x8(Ne)))

///|
pub let i16x8_lt_s : InstrType = VecCompare(V128(I16x8(LtS)))

///|
pub let i16x8_lt_u : InstrType = VecCompare(V128(I16x8(LtU)))

///|
pub let i16x8_le_s : InstrType = VecCompare(V128(I16x8(LeS)))

///|
pub let i16x8_le_u : InstrType = VecCompare(V128(I16x8(LeU)))

///|
pub let i16x8_gt_s : InstrType = VecCompare(V128(I16x8(GtS)))

///|
pub let i16x8_gt_u : InstrType = VecCompare(V128(I16x8(GtU)))

///|
pub let i16x8_ge_s : InstrType = VecCompare(V128(I16x8(GeS)))

///|
pub let i16x8_ge_u : InstrType = VecCompare(V128(I16x8(GeU)))

///|
pub let i16x8_neg : InstrType = VecUnary(V128(I16x8(Neg)))

///|
pub let i16x8_bitmask : InstrType = VecBitmask(V128(I16x8(Bitmask)))

///|
pub let i16x8_all_true : InstrType = VecTest(V128(I16x8(AllTrue)))

///|
pub let i16x8_narrow_i32x4_s : InstrType = VecBinary(V128(I16x8(NarrowS)))

///|
pub let i16x8_narrow_i32x4_u : InstrType = VecBinary(V128(I16x8(NarrowU)))

///|
pub let i16x8_shl : InstrType = VecShift(V128(I16x8(Shl)))

///|
pub let i16x8_shr_s : InstrType = VecShift(V128(I16x8(ShrS)))

///|
pub let i16x8_shr_u : InstrType = VecShift(V128(I16x8(ShrU)))

///|
pub let i16x8_add : InstrType = VecBinary(V128(I16x8(Add)))

///|
pub let i16x8_add_sat_s : InstrType = VecBinary(V128(I16x8(AddSatS)))

///|
pub let i16x8_add_sat_u : InstrType = VecBinary(V128(I16x8(AddSatU)))

///|
pub let i16x8_sub : InstrType = VecBinary(V128(I16x8(Sub)))

///|
pub let i16x8_sub_sat_s : InstrType = VecBinary(V128(I16x8(SubSatS)))

///|
pub let i16x8_sub_sat_u : InstrType = VecBinary(V128(I16x8(SubSatU)))

///|
pub let i16x8_mul : InstrType = VecBinary(V128(I16x8(Mul)))

///|
pub let i16x8_abs : InstrType = VecUnary(V128(I16x8(Abs)))

///|
pub let i16x8_min_s : InstrType = VecBinary(V128(I16x8(MinS)))

///|
pub let i16x8_min_u : InstrType = VecBinary(V128(I16x8(MinU)))

///|
pub let i16x8_max_s : InstrType = VecBinary(V128(I16x8(MaxS)))

///|
pub let i16x8_max_u : InstrType = VecBinary(V128(I16x8(MaxU)))

///|
pub let i16x8_avgr_u : InstrType = VecBinary(V128(I16x8(AvgrU)))

///|
pub let i16x8_extmul_low_i8x16_s : InstrType = VecBinary(
  V128(I16x8(ExtMulLowS)),
)

///|
pub let i16x8_extmul_high_i8x16_s : InstrType = VecBinary(
  V128(I16x8(ExtMulHighS)),
)

///|
pub let i16x8_extmul_low_i8x16_u : InstrType = VecBinary(
  V128(I16x8(ExtMulLowU)),
)

///|
pub let i16x8_extmul_high_i8x16_u : InstrType = VecBinary(
  V128(I16x8(ExtMulHighU)),
)

///|
pub let i16x8_q15mulr_sat_s : InstrType = VecBinary(V128(I16x8(Q15MulRSatS)))

///|
pub let i16x8_extadd_pairwise_i8x16_s : InstrType = VecConvert(
  V128(I16x8(ExtAddPairwiseS)),
)

///|
pub let i16x8_extadd_pairwise_i8x16_u : InstrType = VecConvert(
  V128(I16x8(ExtAddPairwiseU)),
)

// i32x4 operations

///|
pub let i32x4_splat : InstrType = VecSplat(V128(I32x4(Splat)))

///|
pub fn i32x4_extract_lane(i : Int) -> InstrType {
  VecExtract(V128(I32x4(Extract(i, ()))))
}

///|
pub fn i32x4_replace_lane(i : Int) -> InstrType {
  VecReplace(V128(I32x4(Replace(i))))
}

///|
pub let i32x4_eq : InstrType = VecCompare(V128(I32x4(Eq)))

///|
pub let i32x4_ne : InstrType = VecCompare(V128(I32x4(Ne)))

///|
pub let i32x4_lt_s : InstrType = VecCompare(V128(I32x4(LtS)))

///|
pub let i32x4_lt_u : InstrType = VecCompare(V128(I32x4(LtU)))

///|
pub let i32x4_le_s : InstrType = VecCompare(V128(I32x4(LeS)))

///|
pub let i32x4_le_u : InstrType = VecCompare(V128(I32x4(LeU)))

///|
pub let i32x4_gt_s : InstrType = VecCompare(V128(I32x4(GtS)))

///|
pub let i32x4_gt_u : InstrType = VecCompare(V128(I32x4(GtU)))

///|
pub let i32x4_ge_s : InstrType = VecCompare(V128(I32x4(GeS)))

///|
pub let i32x4_ge_u : InstrType = VecCompare(V128(I32x4(GeU)))

///|
pub let i32x4_abs : InstrType = VecUnary(V128(I32x4(Abs)))

///|
pub let i32x4_neg : InstrType = VecUnary(V128(I32x4(Neg)))

///|
pub let i32x4_bitmask : InstrType = VecBitmask(V128(I32x4(Bitmask)))

///|
pub let i32x4_all_true : InstrType = VecTest(V128(I32x4(AllTrue)))

///|
pub let i32x4_extend_low_i16x8_s : InstrType = VecConvert(
  V128(I32x4(ExtendLowS)),
)

///|
pub let i32x4_extend_high_i16x8_s : InstrType = VecConvert(
  V128(I32x4(ExtendHighS)),
)

///|
pub let i32x4_extend_low_i16x8_u : InstrType = VecConvert(
  V128(I32x4(ExtendLowU)),
)

///|
pub let i32x4_extend_high_i16x8_u : InstrType = VecConvert(
  V128(I32x4(ExtendHighU)),
)

///|
pub let i32x4_shl : InstrType = VecShift(V128(I32x4(Shl)))

///|
pub let i32x4_shr_s : InstrType = VecShift(V128(I32x4(ShrS)))

///|
pub let i32x4_shr_u : InstrType = VecShift(V128(I32x4(ShrU)))

///|
pub let i32x4_add : InstrType = VecBinary(V128(I32x4(Add)))

///|
pub let i32x4_sub : InstrType = VecBinary(V128(I32x4(Sub)))

///|
pub let i32x4_min_s : InstrType = VecBinary(V128(I32x4(MinS)))

///|
pub let i32x4_min_u : InstrType = VecBinary(V128(I32x4(MinU)))

///|
pub let i32x4_max_s : InstrType = VecBinary(V128(I32x4(MaxS)))

///|
pub let i32x4_max_u : InstrType = VecBinary(V128(I32x4(MaxU)))

///|
pub let i32x4_mul : InstrType = VecBinary(V128(I32x4(Mul)))

///|
pub let i32x4_dot_i16x8_s : InstrType = VecBinary(V128(I32x4(DotS)))

///|
pub let i32x4_trunc_sat_f32x4_s : InstrType = VecConvert(
  V128(I32x4(TruncSatSF32x4)),
)

///|
pub let i32x4_trunc_sat_f32x4_u : InstrType = VecConvert(
  V128(I32x4(TruncSatUF32x4)),
)

///|
pub let i32x4_trunc_sat_f64x2_s_zero : InstrType = VecConvert(
  V128(I32x4(TruncSatSZeroF64x2)),
)

///|
pub let i32x4_trunc_sat_f64x2_u_zero : InstrType = VecConvert(
  V128(I32x4(TruncSatUZeroF64x2)),
)

///|
pub let i32x4_extmul_low_i16x8_s : InstrType = VecBinary(
  V128(I32x4(ExtMulLowS)),
)

///|
let i32x4_extmul_high_i16x8_s : InstrType = VecBinary(V128(I32x4(ExtMulHighS)))

///|
let i32x4_extmul_low_i16x8_u : InstrType = VecBinary(V128(I32x4(ExtMulLowU)))

///|
let i32x4_extmul_high_i16x8_u : InstrType = VecBinary(V128(I32x4(ExtMulHighU)))

///|
let i32x4_extadd_pairwise_i16x8_s : InstrType = VecConvert(
  V128(I32x4(ExtAddPairwiseS)),
)

///|
let i32x4_extadd_pairwise_i16x8_u : InstrType = VecConvert(
  V128(I32x4(ExtAddPairwiseU)),
)

///|
let i64x2_splat : InstrType = VecSplat(V128(I64x2(Splat)))

///|
fn i64x2_extract_lane(i : Int) -> InstrType {
  VecExtract(V128(I64x2(Extract(i, ()))))
}

///|
fn i64x2_replace_lane(i : Int) -> InstrType {
  VecReplace(V128(I64x2(Replace(i))))
}

///|
let i64x2_extend_low_i32x4_s : InstrType = VecConvert(V128(I64x2(ExtendLowS)))

///|
let i64x2_extend_high_i32x4_s : Instr = VecConvert(V128(I64x2(ExtendHighS)))

///|
let i64x2_extend_low_i32x4_u : InstrType = VecConvert(V128(I64x2(ExtendLowU)))

///|
let i64x2_extend_high_i32x4_u : InstrType = VecConvert(V128(I64x2(ExtendHighU)))

///|
let i64x2_eq : InstrType = VecCompare(V128(I64x2(Eq)))

///|
let i64x2_ne : InstrType = VecCompare(V128(I64x2(Ne)))

///|
let i64x2_lt_s : InstrType = VecCompare(V128(I64x2(LtS)))

///|
let i64x2_le_s : InstrType = VecCompare(V128(I64x2(LeS)))

///|
let i64x2_gt_s : InstrType = VecCompare(V128(I64x2(GtS)))

///|
let i64x2_ge_s : InstrType = VecCompare(V128(I64x2(GeS)))

///|
let i64x2_abs : InstrType = VecUnary(V128(I64x2(Abs)))

///|
let i64x2_neg : InstrType = VecUnary(V128(I64x2(Neg)))

///|
let i64x2_bitmask : InstrType = VecBitmask(V128(I64x2(Bitmask)))

///|
let i64x2_all_true : InstrType = VecTest(V128(I64x2(AllTrue)))

///|
let i64x2_add : InstrType = VecBinary(V128(I64x2(Add)))

///|
let i64x2_sub : InstrType = VecBinary(V128(I64x2(Sub)))

///|
let i64x2_mul : InstrType = VecBinary(V128(I64x2(Mul)))

///|
let i64x2_shl : InstrType = VecShift(V128(I64x2(Shl)))

///|
let i64x2_shr_s : InstrType = VecShift(V128(I64x2(ShrS)))

///|
let i64x2_shr_u : InstrType = VecShift(V128(I64x2(ShrU)))

///|
let i64x2_extmul_low_i32x4_s : InstrType = VecBinary(V128(I64x2(ExtMulLowS)))

///|
let i64x2_extmul_high_i32x4_s : InstrType = VecBinary(V128(I64x2(ExtMulHighS)))

///|
let i64x2_extmul_low_i32x4_u : InstrType = VecBinary(V128(I64x2(ExtMulLowU)))

///|
let i64x2_extmul_high_i32x4_u : InstrType = VecBinary(V128(I64x2(ExtMulHighU)))

///|
let f32x4_splat : InstrType = VecSplat(V128(F32x4(Splat)))

///|
fn f32x4_extract_lane(i : Int) -> InstrType {
  VecExtract(V128(F32x4(Extract(i, ()))))
}

///|
fn f32x4_replace_lane(i : Int) -> InstrType {
  VecReplace(V128(F32x4(Replace(i))))
}

///|
let f32x4_eq : InstrType = VecCompare(V128(F32x4(Eq)))

///|
let f32x4_ne : InstrType = VecCompare(V128(F32x4(Ne)))

///|
let f32x4_lt : InstrType = VecCompare(V128(F32x4(Lt)))

///|
let f32x4_le : InstrType = VecCompare(V128(F32x4(Le)))

///|
let f32x4_gt : InstrType = VecCompare(V128(F32x4(Gt)))

///|
let f32x4_ge : InstrType = VecCompare(V128(F32x4(Ge)))

///|
let f32x4_abs : InstrType = VecUnary(V128(F32x4(Abs)))

///|
let f32x4_neg : InstrType = VecUnary(V128(F32x4(Neg)))

///|
let f32x4_sqrt : InstrType = VecUnary(V128(F32x4(Sqrt)))

///|
let f32x4_ceil : InstrType = VecUnary(V128(F32x4(Ceil)))

///|
let f32x4_floor : InstrType = VecUnary(V128(F32x4(Floor)))

///|
let f32x4_trunc : InstrType = VecUnary(V128(F32x4(Trunc)))

///|
let f32x4_nearest : InstrType = VecUnary(V128(F32x4(Nearest)))

///|
let f32x4_add : InstrType = VecBinary(V128(F32x4(Add)))

///|
let f32x4_sub : InstrType = VecBinary(V128(F32x4(Sub)))

///|
let f32x4_mul : InstrType = VecBinary(V128(F32x4(Mul)))

///|
let f32x4_div : InstrType = VecBinary(V128(F32x4(Div)))

///|
let f32x4_min : InstrType = VecBinary(V128(F32x4(Min)))

///|
let f32x4_max : InstrType = VecBinary(V128(F32x4(Max)))

///|
let f32x4_pmin : InstrType = VecBinary(V128(F32x4(Pmin)))

///|
let f32x4_pmax : InstrType = VecBinary(V128(F32x4(Pmax)))

///|
let f32x4_demote_f64x2_zero : InstrType = VecConvert(
  V128(F32x4(DemoteZeroF64x2)),
)

///|
let f32x4_convert_i32x4_s : InstrType = VecConvert(V128(F32x4(ConvertSI32x4)))

///|
let f32x4_convert_i32x4_u : InstrType = VecConvert(V128(F32x4(ConvertUI32x4)))

///|
let f64x2_splat : InstrType = VecSplat(V128(F64x2(Splat)))

///|
fn f64x2_extract_lane(i : Int) -> InstrType {
  VecExtract(V128(F64x2(Extract(i, ()))))
}

///|
fn f64x2_replace_lane(i : Int) -> InstrType {
  VecReplace(V128(F64x2(Replace(i))))
}

///|
let f64x2_eq : InstrType = VecCompare(V128(F64x2(Eq)))

///|
let f64x2_ne : InstrType = VecCompare(V128(F64x2(Ne)))

///|
let f64x2_lt : InstrType = VecCompare(V128(F64x2(Lt)))

///|
let f64x2_le : InstrType = VecCompare(V128(F64x2(Le)))

///|
let f64x2_gt : InstrType = VecCompare(V128(F64x2(Gt)))

///|
let f64x2_ge : InstrType = VecCompare(V128(F64x2(Ge)))

///|
let f64x2_neg : InstrType = VecUnary(V128(F64x2(Neg)))

///|
let f64x2_sqrt : InstrType = VecUnary(V128(F64x2(Sqrt)))

///|
let f64x2_ceil : InstrType = VecUnary(V128(F64x2(Ceil)))

///|
let f64x2_floor : InstrType = VecUnary(V128(F64x2(Floor)))

///|
let f64x2_trunc : InstrType = VecUnary(V128(F64x2(Trunc)))

///|
let f64x2_nearest : InstrType = VecUnary(V128(F64x2(Nearest)))

///|
let f64x2_add : InstrType = VecBinary(V128(F64x2(Add)))

///|
let f64x2_sub : InstrType = VecBinary(V128(F64x2(Sub)))

///|
let f64x2_mul : InstrType = VecBinary(V128(F64x2(Mul)))

///|
let f64x2_div : InstrType = VecBinary(V128(F64x2(Div)))

///|
let f64x2_min : InstrType = VecBinary(V128(F64x2(Min)))

///|
let f64x2_max : InstrType = VecBinary(V128(F64x2(Max)))

///|
let f64x2_abs : InstrType = VecUnary(V128(F64x2(Abs)))

///|
let f64x2_pmin : InstrType = VecBinary(V128(F64x2(Pmin)))

///|
let f64x2_pmax : InstrType = VecBinary(V128(F64x2(Pmax)))

///|
let f64x2_promote_low_f32x4 : InstrType = VecConvert(
  V128(F64x2(PromoteLowF32x4)),
)

///|
let f64x2_convert_low_i32x4_s : InstrType = VecConvert(
  V128(F64x2(ConvertSI32x4)),
)

///|
let f64x2_convert_low_i32x4_u : InstrType = VecConvert(
  V128(F64x2(ConvertUI32x4)),
)

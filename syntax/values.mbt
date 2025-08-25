// Values and operators

///|
pub enum Op[T1, T2, T3, T4] {
  I32(T1)
  I64(T2)
  F32(T3)
  F64(T4)
}

///|
pub typealias Op[Int, Int64, Float, Double] as ValuesNum

///|
pub enum VecOp[T] {
  V128(T)
}

///|
pub typealias VecOp[String] as ValuesVec

///|
pub fn[T1, T2, T3, T4] type_of_num(v : Op[T1, T2, T3, T4]) -> NumType {
  match v {
    I32(_) => I32Type
    I64(_) => I64Type
    F32(_) => F32Type
    F64(_) => F64Type
  }
}

///|
pub fn[T] type_of_vec(v : VecOp[T]) -> VecType {
  match v {
    V128(_) => V128Type
  }
}

// V128

///|
pub enum V128LaneOp[T1, T2, T3, T4, T5, T6] {
  I8x16(T1)
  I16x8(T2)
  I32x4(T3)
  I64x2(T4)
  F32x4(T5)
  F64x2(T6)
}

///|
pub fn[T1, T2, T3, T4, T5, T6] type_of_lane(
  laneop : V128LaneOp[T1, T2, T3, T4, T5, T6],
) -> NumType {
  match laneop {
    I8x16(_) | I16x8(_) | I32x4(_) => I32Type
    I64x2(_) => I64Type
    F32x4(_) => F32Type
    F64x2(_) => F64Type
  }
}

///|
pub fn[T1, T2, T3, T4, T5, T6] num_of_lanes(
  laneop : V128LaneOp[T1, T2, T3, T4, T5, T6],
) -> Int {
  match laneop {
    I8x16(_) => 16
    I16x8(_) => 8
    I32x4(_) => 4
    I64x2(_) => 2
    F32x4(_) => 4
    F64x2(_) => 2
  }
}

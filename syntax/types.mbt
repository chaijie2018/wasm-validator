///|
pub enum NumType {
  I32Type
  I64Type
  F32Type
  F64Type
} derive(Eq, Show)

///|
pub enum VecType {
  V128Type
} derive(Eq, Show)

///|
pub enum RefType {
  FuncRefType
  ExternRefType
} derive(Eq, Show)

///|
pub enum ValueType {
  NumType(NumType)
  VecType(VecType)
  RefType(RefType)
} derive(Eq, Show)

///|
pub typealias Array[ValueType] as ResultType

///|
pub enum FuncType {
  FuncType(ResultType, ResultType)
}

///|
pub struct Limits {
  min : UInt
  max : UInt?
}

///|
pub enum Mutability {
  Immutable
  Mutable
}

///|
pub struct TableType {
  limits : Limits
  ref_type : RefType
}

///|
pub struct MemoryType {
  limits : Limits
}

///|
pub struct GlobalType {
  value_type : ValueType
  mutability : Mutability
}

///|
pub enum ExternType {
  ExternFuncType(FuncType)
  ExternTableType(TableType)
  ExternMemoryType(MemoryType)
  ExternGlobalType(GlobalType)
}

///|
pub enum Extension {
  SX
  ZX
}

///|
pub enum PackSize {
  Pack8
  Pack16
  Pack32
  Pack64
}

///|
pub enum PackShape {
  Pack8x8
  Pack16x4
  Pack32x2
}

///|
pub enum VecExtension {
  ExtLane(PackShape, Extension)
  ExtSplat
  ExtZero
}

///|
pub fn packed_size(s : PackSize) -> Int {
  match s {
    Pack8 => 1
    Pack16 => 2
    Pack32 => 4
    Pack64 => 8
  }
}

///|
pub fn num_size(t : NumType) -> Int {
  match t {
    I32Type | F32Type => 4
    I64Type | F64Type => 8
  }
}

///|
pub fn vec_size(t : VecType) -> Int {
  match t {
    V128Type => 16
  }
}

///|
pub fn is_num_type(t : ValueType) -> Bool {
  match t {
    NumType(_) => true
    _ => false
  }
}

///|
pub fn is_vec_type(t : ValueType) -> Bool {
  match t {
    VecType(_) => true
    _ => false
  }
}

///|
pub fn is_ref_type(t : ValueType) -> Bool {
  match t {
    RefType(_) => true
    _ => false
  }
}

// Filter function: extract specific types from an external type list

///|
pub fn funcs(extern_types : Array[ExternType]) -> Array[FuncType] {
  extern_types.filter_map(fn(et) {
    match et {
      ExternFuncType(t) => Some(t)
      _ => None
    }
  })
}

///|
pub fn tables(extern_types : Array[ExternType]) -> Array[TableType] {
  extern_types.filter_map(fn(et) {
    match et {
      ExternTableType(t) => Some(t)
      _ => None
    }
  })
}

///|
pub fn memories(extern_types : Array[ExternType]) -> Array[MemoryType] {
  extern_types.filter_map(fn(et) {
    match et {
      ExternMemoryType(t) => Some(t)
      _ => None
    }
  })
}

///|
pub fn globals(extern_types : Array[ExternType]) -> Array[GlobalType] {
  extern_types.filter_map(fn(et) {
    match et {
      ExternGlobalType(t) => Some(t)
      _ => None
    }
  })
}

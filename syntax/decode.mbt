// Decoding stream

///|
pub struct Stream {
  name : Bytes
  bytes : Bytes
  pos : Ref[Int]
}

///|
pub fn stream(name : Bytes, bs : Bytes) -> Stream {
  { name, bytes: bs, pos: { val: 0 } }
}

///|
pub fn len(s : Stream) -> Int {
  s.bytes.length()
}

///|
pub fn pos(s : Stream) -> Int {
  s.pos.val
}

///|
pub fn eos(s : Stream) -> Bool {
  pos(s) == len(s)
}

///|
pub fn reset(s : Stream, pos : Int) -> Unit {
  s.pos.val = pos
}

///|
pub fn check(n : Int, s : Stream) -> Unit raise {
  if pos(s) + n > len(s) {
    fail("end of stream")
  }
}

///|
pub fn skip(n : Int, s : Stream) -> Unit raise {
  if n < 0 {
    fail("negative skip")
  } else {
    check(n, s)
    s.pos.val = s.pos.val + n
  }
}

///|
pub fn read(s : Stream) -> Byte {
  s.bytes[s.pos.val]
}

///|
pub fn peek2(s : Stream) -> Byte? {
  if eos(s) {
    None
  } else {
    Some(read(s))
  }
}

///|
pub fn get(s : Stream) -> Byte raise {
  check(1, s)
  let b = read(s)
  skip(1, s)
  b
}

///|
pub fn get_string(n : Int, s : Stream) -> Bytes raise {
  let i = pos(s)
  skip(n, s)
  s.bytes[i:i + n].to_bytes()
}

// Error handling helper functions

///|
pub fn string_of_byte(b : Int) -> String {
  b.to_string()
}

///|
pub fn string_of_multi(n : Int64) -> String {
  n.to_string()
}

///|
pub fn require2(b : Bool, s : Stream, pos : Int, msg : String) -> Unit raise {
  if not(b) {
    fail("Error at " + pos.to_string() + ": " + msg)
  }
}

///|
pub fn[T] guard2(f : (Stream) -> T raise, s : Stream) -> T raise {
  f(s)
}

///|
pub fn expect(b : Int, s : Stream, msg : String) -> Unit raise {
  let result = guard2(get, s).to_int()
  let bool = result == b
  require2(bool, s, pos(s) - 1, msg)
}

///|
pub fn illegal(s : Stream, pos : Int, b : Int) -> String {
  "illegal opcode " + string_of_byte(b)
}

///|
pub fn illegal2(s : Stream, pos : Int, b : Int, n : Int64) -> String {
  "illegal opcode " + string_of_byte(b) + " " + string_of_multi(n)
}

///|
pub fn[T] at(f : (Stream) -> T raise?, s : Stream) -> T raise? {
  f(s)
}

// Generic value readers

///|
pub fn byte(s : Stream) -> Int raise {
  guard2(get, s).to_int()
}

///|
pub fn word16(s : Stream) -> Int raise {
  let lo = byte(s)
  let hi = byte(s)
  (hi << 8) + lo
}

///|
pub fn word32(s : Stream) -> Int raise {
  let lo = word16(s)
  let hi = word16(s)
  (hi << 16) + lo
}

///|
pub fn word64(s : Stream) -> Int64 raise {
  let lo = word32(s).to_int64()
  let hi = word32(s).to_int64()
  (hi << 32) + lo
}

// LEB128 decoding

///|
pub fn uN(n : Int, s : Stream) -> Int64 raise {
  fn decode(n : Int, s : Stream) -> Int64 raise {
    require2(n > 0, s, pos(s), "integer representation too long")
    let b = byte(s)
    let bool = n >= 7 || (b & 0x7f) < 1 << n
    require2(bool, s, pos(s) - 1, "integer too large")
    let x = b.land(0x7f).to_int64()
    if (b & 0x80) == 0 {
      x
    } else {
      let rest = decode(n - 7, s)
      x | (rest << 7)
    }
  }

  decode(n, s)
}

///|
pub fn sN(n : Int, s : Stream) -> Int64 raise {
  fn decode(n : Int, s : Stream) -> Int64 raise {
    require2(n > 0, s, pos(s), "integer representation too long")
    let b = byte(s)
    let mask = (-1 << (n - 1)) & 0x7f
    let bool = n >= 7 || (b & mask) == 0 || (b & mask) == mask
    require2(bool, s, pos(s) - 1, "integer too large")
    let x = (b & 0x7f).to_int64()
    if (b & 0x80) == 0 {
      if (b & 0x40) == 0 {
        x
      } else {
        x | (-1L ^ 0x7fL)
      }
    } else {
      let rest = decode(n - 7, s)
      x | (rest << 7)
    }
  }

  decode(n, s)
}

// Specific size readers

///|
pub fn u1(s : Stream) -> Int raise {
  uN(1, s).to_int()
}

///|
pub fn u32(s : Stream) -> Int raise {
  uN(32, s).to_int()
}

///|
pub fn s7(s : Stream) -> Int raise {
  sN(7, s).to_int()
}

///|
pub fn s32(s : Stream) -> Int raise {
  sN(32, s).to_int()
}

///|
pub fn s33(s : Stream) -> Int raise {
  sN(33, s).to_int()
}

///|
pub fn s64(s : Stream) -> Int64 raise {
  sN(64, s)
}

///|
pub fn f32(s : Stream) -> Float raise {
  word32(s).to_float()
}

///|
pub fn f64(s : Stream) -> Double raise {
  word64(s).to_double()
}

///|
pub fn v128(s : Stream) -> Bytes raise {
  guard2(fn(s) { get_string(vec_size(V128Type), s) }, s)
}

///|
pub fn len32(s : Stream) -> Int raise {
  let pos_val = pos(s)
  let n = u32(s)
  if n <= len(s) - pos_val {
    n
  } else {
    fail("length out of bounds")
  }
}

///|
pub fn bool(s : Stream) -> Bool raise {
  u1(s) == 1
}

///|
pub fn string(s : Stream) -> Bytes raise {
  let n = len32(s)
  guard2(fn(s) { get_string(n, s) }, s)
}

///|
pub fn[T] list2(
  f : (Stream) -> T raise,
  n : Int,
  s : Stream,
) -> @list.List[T] raise {
  @list.repeat(n, f(s))
}

///|
pub fn name(s : Stream) -> Bytes raise {
  // For simplicity, assuming UTF-8 validation is built into string handling
  string(s)
}

///|
pub fn[T] sized(f : (Int, Stream) -> T raise, s : Stream) -> T raise {
  let size = len32(s)
  let start = pos(s)
  let x = f(size, s)
  require2(pos(s) == start + size, s, start, "section size mismatch")
  x
}

// Type readers

///|
pub fn num_type(s : Stream) -> NumType raise {
  let val = s7(s)
  match val {
    -0x01 => I32Type
    -0x02 => I64Type
    -0x03 => F32Type
    -0x04 => F64Type
    _ => fail("malformed number type")
  }
}

///|
pub fn vec_type(s : Stream) -> VecType raise {
  let val = s7(s)
  match val {
    -0x05 => V128Type
    _ => fail("malformed vector type")
  }
}

///|
pub fn ref_type(s : Stream) -> RefType raise {
  let val = s7(s)
  match val {
    -0x10 => FuncRefType
    -0x11 => ExternRefType
    _ => fail("malformed reference type")
  }
}

///|
pub fn[T] either(fs : Array[(Stream) -> T raise], s : Stream) -> T raise {
  fn try_alternatives(
    fs : Array[(Stream) -> T raise],
    idx : Int,
    s : Stream,
  ) -> T raise {
    if idx >= fs.length() {
      fail("No alternative succeeded")
    } else if idx == fs.length() - 1 {
      fs[idx](s)
    } else {
      fs[idx](s) catch {
        _ => {
          reset(s, pos(s))
          try_alternatives(fs, idx + 1, s)
        }
      }
    }
  }

  try_alternatives(fs, 0, s)
}

///|
pub fn value_type(s : Stream) -> ValueType raise {
  either(
    [
      fn(s) { ValueType::Num(num_type(s)) },
      fn(s) { ValueType::Vec(vec_type(s)) },
      fn(s) { ValueType::Ref(ref_type(s)) },
    ],
    s,
  )
}

///|
fn[T] opt2(f : (Stream) -> T raise, b : Bool, s : Stream) -> T? raise {
  if b {
    Some(f(s))
  } else {
    None
  }
}

///|
pub fn[T] vec(f : (Stream) -> T raise, s : Stream) -> @list.List[T] raise {
  let n = len32(s)
  list2(f, n, s)
}

///|
pub fn result_type(s : Stream) -> @list.List[ValueType] raise {
  vec(value_type, s)
}

///|
pub fn func_type(s : Stream) -> FuncType raise {
  let val = s7(s)
  match val {
    -0x20 => {
      let ts1 = result_type(s)
      let ts2 = result_type(s)
      FuncType(ts1, ts2)
    }
    _ => fail("malformed function type")
  }
}

///|
pub fn limits(uN_func : (Stream) -> Int raise, s : Stream) -> Limits raise {
  let has_max = bool(s)
  let min = uN_func(s)
  let max = opt2(uN_func, has_max, s)
  {
    min: min.to_uint(),
    max: if max is Some(val) {
      Some(val.to_uint())
    } else {
      None
    },
  }
}

///|
pub fn table_type(s : Stream) -> TableType raise {
  let t = ref_type(s)
  let lim = limits(u32, s)
  { limits: lim, ref_type: t }
}

///|
pub fn memory_type(s : Stream) -> MemoryType raise {
  let lim = limits(u32, s)
  { limits: lim }
}

///|
pub fn mutability(s : Stream) -> Mutability raise {
  let val = byte(s)
  match val {
    0 => Immutable
    1 => Mutable
    _ => fail("malformed mutability")
  }
}

///|
pub fn global_type(s : Stream) -> GlobalType raise {
  let t = value_type(s)
  let mu = mutability(s)
  { value_type: t, mutability: mu }
}

// Instructions

///|
pub fn var2(s : Stream) -> Int raise {
  u32(s)
}

///|
pub fn op(s : Stream) -> Int raise {
  byte(s)
}

///|
pub fn end2(s : Stream) -> Unit raise {
  expect(0x0b, s, "END opcode expected")
}

///|
pub fn zero2(s : Stream) -> Unit raise {
  expect(0x00, s, "zero byte expected")
}

///|
pub fn memop(s : Stream) -> (Int, Int) raise {
  let align = u32(s)
  require2(align < 32, s, pos(s) - 1, "malformed memop flags")
  let offset = u32(s)
  (align, offset)
}

///|
pub fn block_type2(s : Stream) -> BlockType raise {
  let p = pos(s)
  either(
    [
      fn(s) {
        let x = at(s33, s)
        require2(x >= 0, s, p, "")
        VarBlockType(x)
      },
      fn(s) {
        expect(0x40, s, "")
        ValBlockType(None)
      },
      fn(s) { ValBlockType(Some(value_type(s))) },
    ],
    s,
  )
}

///|
pub fn instr2(s : Stream) -> InstrType raise {
  let pos_val = pos(s)
  match op(s) {
    0x00 => Unreachable
    0x01 => Nop
    0x02 => {
      let bt = block_type2(s)
      let es = instr_block(s)
      end2(s)
      block2(bt, es)
    }
    0x03 => {
      let bt = block_type2(s)
      let es = instr_block(s)
      end2(s)
      loop2(bt, es)
    }
    0x04 => {
      let bt = block_type2(s)
      let es1 = instr_block(s)
      match peek2(s) {
        Some(0x05) => {
          expect(0x05, s, "ELSE or END opcode expected")
          let es2 = instr_block(s)
          end2(s)
          if2(bt, es1, es2)
        }
        _ => {
          end2(s)
          if2(bt, es1, @list.empty())
        }
      }
    }
    0x05 => fail("misplaced ELSE opcode")
    0x06 | 0x07 | 0x08 | 0x09 | 0x0a as op_code =>
      fail(illegal(s, pos_val, op_code))
    0x0b => fail("misplaced END opcode")
    0x0c => br(at(var2, s))
    0x0d => br_if(at(var2, s))
    0x0e => {
      let xs = vec(fn(s) { at(var2, s) }, s)
      let x = at(var2, s)
      br_table(xs, x)
    }
    0x0f => Return
    0x10 => call(at(var2, s))
    0x11 => {
      let y = at(var2, s)
      let x = at(var2, s)
      call_indirect(x, y)
    }
    0x12 | 0x13 | 0x14 | 0x15 | 0x16 | 0x17 | 0x18 | 0x19 as op_code =>
      fail(illegal(s, pos_val, op_code))
    0x1a => Drop
    0x1b => select(None)
    0x1c => select(Some(vec(value_type, s)))
    0x1d | 0x1e | 0x1f as op_code => fail(illegal(s, pos_val, op_code))
    0x20 => local_get(at(var2, s))
    0x21 => local_set(at(var2, s))
    0x22 => local_tee(at(var2, s))
    0x23 => global_get(at(var2, s))
    0x24 => global_set(at(var2, s))
    0x25 => table_get(at(var2, s))
    0x26 => table_set(at(var2, s))
    0x27 as op_code => fail(illegal(s, pos_val, op_code))

    // Memory operations
    0x28 => {
      let (a, o) = memop(s)
      i32_load(a, o)
    }
    0x29 => {
      let (a, o) = memop(s)
      i64_load(a, o)
    }
    0x2a => {
      let (a, o) = memop(s)
      f32_load(a, o)
    }
    0x2b => {
      let (a, o) = memop(s)
      f64_load(a, o)
    }
    0x2c => {
      let (a, o) = memop(s)
      i32_load8_s(a, o)
    }
    0x2d => {
      let (a, o) = memop(s)
      i32_load8_u(a, o)
    }
    0x2e => {
      let (a, o) = memop(s)
      i32_load16_s(a, o)
    }
    0x2f => {
      let (a, o) = memop(s)
      i32_load16_u(a, o)
    }
    0x30 => {
      let (a, o) = memop(s)
      i64_load8_s(a, o)
    }
    0x31 => {
      let (a, o) = memop(s)
      i64_load8_u(a, o)
    }
    0x32 => {
      let (a, o) = memop(s)
      i64_load16_s(a, o)
    }
    0x33 => {
      let (a, o) = memop(s)
      i64_load16_u(a, o)
    }
    0x34 => {
      let (a, o) = memop(s)
      i64_load32_s(a, o)
    }
    0x35 => {
      let (a, o) = memop(s)
      i64_load32_u(a, o)
    }
    0x36 => {
      let (a, o) = memop(s)
      i32_store(a, o)
    }
    0x37 => {
      let (a, o) = memop(s)
      i64_store(a, o)
    }
    0x38 => {
      let (a, o) = memop(s)
      f32_store(a, o)
    }
    0x39 => {
      let (a, o) = memop(s)
      f64_store(a, o)
    }
    0x3a => {
      let (a, o) = memop(s)
      i32_store8(a, o)
    }
    0x3b => {
      let (a, o) = memop(s)
      i32_store16(a, o)
    }
    0x3c => {
      let (a, o) = memop(s)
      i64_store8(a, o)
    }
    0x3d => {
      let (a, o) = memop(s)
      i64_store16(a, o)
    }
    0x3e => {
      let (a, o) = memop(s)
      i64_store32(a, o)
    }
    0x3f => {
      zero2(s)
      memory_size
    }
    0x40 => {
      zero2(s)
      memory_grow
    }

    // Constants
    0x41 => i32_const(at(s32, s))
    0x42 => i64_const(at(s64, s))
    0x43 => f32_const(at(f32, s))
    0x44 => f64_const(at(f64, s))

    // i32 comparisons
    0x45 => i32_eqz
    0x46 => i32_eq
    0x47 => i32_ne
    0x48 => i32_lt_s
    0x49 => i32_lt_u
    0x4a => i32_gt_s
    0x4b => i32_gt_u
    0x4c => i32_le_s
    0x4d => i32_le_u
    0x4e => i32_ge_s
    0x4f => i32_ge_u

    // i64 comparisons
    0x50 => i64_eqz
    0x51 => i64_eq
    0x52 => i64_ne
    0x53 => i64_lt_s
    0x54 => i64_lt_u
    0x55 => i64_gt_s
    0x56 => i64_gt_u
    0x57 => i64_le_s
    0x58 => i64_le_u
    0x59 => i64_ge_s
    0x5a => i64_ge_u

    // f32 comparisons
    0x5b => f32_eq
    0x5c => f32_ne
    0x5d => f32_lt
    0x5e => f32_gt
    0x5f => f32_le
    0x60 => f32_ge

    // f64 comparisons
    0x61 => f64_eq
    0x62 => f64_ne
    0x63 => f64_lt
    0x64 => f64_gt
    0x65 => f64_le
    0x66 => f64_ge

    // i32 arithmetic
    0x67 => i32_clz
    0x68 => i32_ctz
    0x69 => i32_popcnt
    0x6a => i32_add
    0x6b => i32_sub
    0x6c => i32_mul
    0x6d => i32_div_s
    0x6e => i32_div_u
    0x6f => i32_rem_s
    0x70 => i32_rem_u
    0x71 => i32_and
    0x72 => i32_or
    0x73 => i32_xor
    0x74 => i32_shl
    0x75 => i32_shr_s
    0x76 => i32_shr_u
    0x77 => i32_rotl
    0x78 => i32_rotr

    // i64 arithmetic
    0x79 => i64_clz
    0x7a => i64_ctz
    0x7b => i64_popcnt
    0x7c => i64_add
    0x7d => i64_sub
    0x7e => i64_mul
    0x7f => i64_div_s
    0x80 => i64_div_u
    0x81 => i64_rem_s
    0x82 => i64_rem_u
    0x83 => i64_and
    0x84 => i64_or
    0x85 => i64_xor
    0x86 => i64_shl
    0x87 => i64_shr_s
    0x88 => i64_shr_u
    0x89 => i64_rotl
    0x8a => i64_rotr

    // f32 arithmetic
    0x8b => f32_abs
    0x8c => f32_neg
    0x8d => f32_ceil
    0x8e => f32_floor
    0x8f => f32_trunc
    0x90 => f32_nearest
    0x91 => f32_sqrt
    0x92 => f32_add
    0x93 => f32_sub
    0x94 => f32_mul
    0x95 => f32_div
    0x96 => f32_min
    0x97 => f32_max
    0x98 => f32_copysign

    // f64 arithmetic
    0x99 => f64_abs
    0x9a => f64_neg
    0x9b => f64_ceil
    0x9c => f64_floor
    0x9d => f64_trunc
    0x9e => f64_nearest
    0x9f => f64_sqrt
    0xa0 => f64_add
    0xa1 => f64_sub
    0xa2 => f64_mul
    0xa3 => f64_div
    0xa4 => f64_min
    0xa5 => f64_max
    0xa6 => f64_copysign

    // Conversions
    0xa7 => i32_wrap_i64
    0xa8 => i32_trunc_f32_s
    0xa9 => i32_trunc_f32_u
    0xaa => i32_trunc_f64_s
    0xab => i32_trunc_f64_u
    0xac => i64_extend_i32_s
    0xad => i64_extend_i32_u
    0xae => i64_trunc_f32_s
    0xaf => i64_trunc_f32_u
    0xb0 => i64_trunc_f64_s
    0xb1 => i64_trunc_f64_u
    0xb2 => f32_convert_i32_s
    0xb3 => f32_convert_i32_u
    0xb4 => f32_convert_i64_s
    0xb5 => f32_convert_i64_u
    0xb6 => f32_demote_f64
    0xb7 => f64_convert_i32_s
    0xb8 => f64_convert_i32_u
    0xb9 => f64_convert_i64_s
    0xba => f64_convert_i64_u
    0xbb => f64_promote_f32

    // Reinterpretations
    0xbc => i32_reinterpret_f32
    0xbd => i64_reinterpret_f64
    0xbe => f32_reinterpret_i32
    0xbf => f64_reinterpret_i64

    // Sign extension
    0xc0 => i32_extend8_s
    0xc1 => i32_extend16_s
    0xc2 => i64_extend8_s
    0xc3 => i64_extend16_s
    0xc4 => i64_extend32_s
    0xc5
    | 0xc6
    | 0xc7
    | 0xc8
    | 0xc9
    | 0xca
    | 0xcb
    | 0xcc
    | 0xcd
    | 0xce
    | 0xcf as op_code => fail(illegal(s, pos_val, op_code))

    // Reference types
    0xd0 => ref_null(ref_type(s))
    0xd1 => ref_is_null
    0xd2 => ref_func(at(var2, s))

    // Multi-byte opcodes
    0xfc =>
      match u32(s) {
        // Saturating truncation
        0x00 => i32_trunc_sat_f32_s
        0x01 => i32_trunc_sat_f32_u
        0x02 => i32_trunc_sat_f64_s
        0x03 => i32_trunc_sat_f64_u
        0x04 => i64_trunc_sat_f32_s
        0x05 => i64_trunc_sat_f32_u
        0x06 => i64_trunc_sat_f64_s
        0x07 => i64_trunc_sat_f64_u

        // Bulk memory operations
        0x08 => {
          let x = at(var2, s)
          zero2(s)
          memory_init(x)
        }
        0x09 => data_drop(at(var2, s))
        0x0a => {
          zero2(s)
          zero2(s)
          memory_copy
        }
        0x0b => {
          zero2(s)
          memory_fill
        }

        // Table operations
        0x0c => {
          let y = at(var2, s)
          let x = at(var2, s)
          table_init(x, y)
        }
        0x0d => elem_drop(at(var2, s))
        0x0e => {
          let x = at(var2, s)
          let y = at(var2, s)
          table_copy(x, y)
        }
        0x0f => table_grow(at(var2, s))
        0x10 => table_size(at(var2, s))
        0x11 => table_fill(at(var2, s))
        n => fail(illegal2(s, pos_val, 0xfc, n.to_int64()))
      }

    // SIMD instructions (0xfd prefix)
    0xfd =>
      match u32(s) {
        // SIMD Memory operations
        0x00 => {
          let (a, o) = memop(s)
          return v128_load(a, o)
        }
        0x01 => {
          let (a, o) = memop(s)
          return v128_load8x8_s(a, o)
        }
        0x02 => {
          let (a, o) = memop(s)
          return v128_load8x8_u(a, o)
        }
        0x03 => {
          let (a, o) = memop(s)
          return v128_load16x4_s(a, o)
        }
        0x04 => {
          let (a, o) = memop(s)
          return v128_load16x4_u(a, o)
        }
        0x05 => {
          let (a, o) = memop(s)
          return v128_load32x2_s(a, o)
        }
        0x06 => {
          let (a, o) = memop(s)
          return v128_load32x2_u(a, o)
        }
        0x07 => {
          let (a, o) = memop(s)
          return v128_load8_splat(a, o)
        }
        0x08 => {
          let (a, o) = memop(s)
          return v128_load16_splat(a, o)
        }
        0x09 => {
          let (a, o) = memop(s)
          return v128_load32_splat(a, o)
        }
        0x0a => {
          let (a, o) = memop(s)
          return v128_load64_splat(a, o)
        }
        0x0b => {
          let (a, o) = memop(s)
          return v128_store(a, o)
        }
        0x0c => return v128_const(at(v128, s))
        0x0d => {
          let a = Array::make(16, byte(s))
          i8x16_shuffle(a)
        }
        0x0e => i8x16_swizzle
        0x0f => i8x16_splat
        0x10 => i16x8_splat
        0x11 => i32x4_splat
        0x12 => i64x2_splat
        0x13 => f32x4_splat
        0x14 => f64x2_splat
        0x15 => {
          let i = byte(s)
          i8x16_extract_lane_s(i)
        }
        0x16 => {
          let i = byte(s)
          i8x16_extract_lane_u(i)
        }
        0x17 => {
          let i = byte(s)
          i8x16_replace_lane(i)
        }
        0x18 => {
          let i = byte(s)
          i16x8_extract_lane_s(i)
        }
        0x19 => {
          let i = byte(s)
          i16x8_extract_lane_u(i)
        }
        0x1a => {
          let i = byte(s)
          i16x8_replace_lane(i)
        }
        0x1b => {
          let i = byte(s)
          i32x4_extract_lane(i)
        }
        0x1c => {
          let i = byte(s)
          i32x4_replace_lane(i)
        }
        0x1d => {
          let i = byte(s)
          i64x2_extract_lane(i)
        }
        0x1e => {
          let i = byte(s)
          i64x2_replace_lane(i)
        }
        0x1f => {
          let i = byte(s)
          f32x4_extract_lane(i)
        }
        0x20 => {
          let i = byte(s)
          f32x4_replace_lane(i)
        }
        0x21 => {
          let i = byte(s)
          f64x2_extract_lane(i)
        }
        0x22 => {
          let i = byte(s)
          f64x2_replace_lane(i)
        }
        0x23 => i8x16_eq
        0x24 => i8x16_ne
        0x25 => i8x16_lt_s
        0x26 => i8x16_lt_u
        0x27 => i8x16_gt_s
        0x28 => i8x16_gt_u
        0x29 => i8x16_le_s
        0x2a => i8x16_le_u
        0x2b => i8x16_ge_s
        0x2c => i8x16_ge_u
        0x2d => i16x8_eq
        0x2e => i16x8_ne
        0x2f => i16x8_lt_s
        0x30 => i16x8_lt_u
        0x31 => i16x8_gt_s
        0x32 => i16x8_gt_u
        0x33 => i16x8_le_s
        0x34 => i16x8_le_u
        0x35 => i16x8_ge_s
        0x36 => i16x8_ge_u
        0x37 => i32x4_eq
        0x38 => i32x4_ne
        0x39 => i32x4_lt_s
        0x3a => i32x4_lt_u
        0x3b => i32x4_gt_s
        0x3c => i32x4_gt_u
        0x3d => i32x4_le_s
        0x3e => i32x4_le_u
        0x3f => i32x4_ge_s
        0x40 => i32x4_ge_u
        0x41 => f32x4_eq
        0x42 => f32x4_ne
        0x43 => f32x4_lt
        0x44 => f32x4_gt
        0x45 => f32x4_le
        0x46 => f32x4_ge
        0x47 => f64x2_eq
        0x48 => f64x2_ne
        0x49 => f64x2_lt
        0x4a => f64x2_gt
        0x4b => f64x2_le
        0x4c => f64x2_ge
        0x4d => v128_not
        0x4e => v128_and
        0x4f => v128_andnot
        0x50 => v128_or
        0x51 => v128_xor
        0x52 => v128_bitselect
        0x53 => v128_any_true
        0x54 => {
          let (a, o) = memop(s)
          let lane = byte(s)
          v128_load8_lane(a, o, lane)
        }
        0x55 => {
          let (a, o) = memop(s)
          let lane = byte(s)
          v128_load16_lane(a, o, lane)
        }
        0x56 => {
          let (a, o) = memop(s)
          let lane = byte(s)
          v128_load32_lane(a, o, lane)
        }
        0x57 => {
          let (a, o) = memop(s)
          let lane = byte(s)
          v128_load64_lane(a, o, lane)
        }
        0x58 => {
          let (a, o) = memop(s)
          let lane = byte(s)
          v128_store8_lane(a, o, lane)
        }
        0x59 => {
          let (a, o) = memop(s)
          let lane = byte(s)
          v128_store16_lane(a, o, lane)
        }
        0x5a => {
          let (a, o) = memop(s)
          let lane = byte(s)
          v128_store32_lane(a, o, lane)
        }
        0x5b => {
          let (a, o) = memop(s)
          let lane = byte(s)
          v128_store64_lane(a, o, lane)
        }
        0x5c => {
          let (a, o) = memop(s)
          v128_load32_zero(a, o)
        }
        0x5d => {
          let (a, o) = memop(s)
          v128_load64_zero(a, o)
        }
        0x5e => f32x4_demote_f64x2_zero
        0x5f => f64x2_promote_low_f32x4
        0x60 => i8x16_abs
        0x61 => i8x16_neg
        0x62 => i8x16_popcnt
        0x63 => i8x16_all_true
        0x64 => i8x16_bitmask
        0x65 => i8x16_narrow_i16x8_s
        0x66 => i8x16_narrow_i16x8_u
        0x67 => f32x4_ceil
        0x68 => f32x4_floor
        0x69 => f32x4_trunc
        0x6a => f32x4_nearest
        0x6b => i8x16_shl
        0x6c => i8x16_shr_s
        0x6d => i8x16_shr_u
        0x6e => i8x16_add
        0x6f => i8x16_add_sat_s
        0x70 => i8x16_add_sat_u
        0x71 => i8x16_sub
        0x72 => i8x16_sub_sat_s
        0x73 => i8x16_sub_sat_u
        0x74 => f64x2_ceil
        0x75 => f64x2_floor
        0x76 => i8x16_min_s
        0x77 => i8x16_min_u
        0x78 => i8x16_max_s
        0x79 => i8x16_max_u
        0x7a => f64x2_trunc
        0x7b => i8x16_avgr_u
        0x7c => i16x8_extadd_pairwise_i8x16_s
        0x7d => i16x8_extadd_pairwise_i8x16_u
        0x7e => i32x4_extadd_pairwise_i16x8_s
        0x7f => i32x4_extadd_pairwise_i16x8_u
        0x80 => i16x8_abs
        0x81 => i16x8_neg
        0x82 => i16x8_q15mulr_sat_s
        0x83 => i16x8_all_true
        0x84 => i16x8_bitmask
        0x85 => i16x8_narrow_i32x4_s
        0x86 => i16x8_narrow_i32x4_u
        0x87 => i16x8_extend_low_i8x16_s
        0x88 => i16x8_extend_high_i8x16_s
        0x89 => i16x8_extend_low_i8x16_u
        0x8a => i16x8_extend_high_i8x16_u
        0x8b => i16x8_shl
        0x8c => i16x8_shr_s
        0x8d => i16x8_shr_u
        0x8e => i16x8_add
        0x8f => i16x8_add_sat_s
        0x90 => i16x8_add_sat_u
        0x91 => i16x8_sub
        0x92 => i16x8_sub_sat_s
        0x93 => i16x8_sub_sat_u
        0x94 => f64x2_nearest
        0x95 => i16x8_mul
        0x96 => i16x8_min_s
        0x97 => i16x8_min_u
        0x98 => i16x8_max_s
        0x99 => i16x8_max_u
        0x9b => i16x8_avgr_u
        0x9c => i16x8_extmul_low_i8x16_s
        0x9d => i16x8_extmul_high_i8x16_s
        0x9e => i16x8_extmul_low_i8x16_u
        0x9f => i16x8_extmul_high_i8x16_u
        0xa0 => i32x4_abs
        0xa1 => i32x4_neg
        0xa3 => i32x4_all_true
        0xa4 => i32x4_bitmask
        0xa7 => i32x4_extend_low_i16x8_s
        0xa8 => i32x4_extend_high_i16x8_s
        0xa9 => i32x4_extend_low_i16x8_u
        0xaa => i32x4_extend_high_i16x8_u
        0xab => i32x4_shl
        0xac => i32x4_shr_s
        0xad => i32x4_shr_u
        0xae => i32x4_add
        0xb1 => i32x4_sub
        0xb5 => i32x4_mul
        0xb6 => i32x4_min_s
        0xb7 => i32x4_min_u
        0xb8 => i32x4_max_s
        0xb9 => i32x4_max_u
        0xba => i32x4_dot_i16x8_s
        0xbc => i32x4_extmul_low_i16x8_s
        0xbd => i32x4_extmul_high_i16x8_s
        0xbe => i32x4_extmul_low_i16x8_u
        0xbf => i32x4_extmul_high_i16x8_u
        0xc0 => i64x2_abs
        0xc1 => i64x2_neg
        0xc3 => i64x2_all_true
        0xc4 => i64x2_bitmask
        0xc7 => i64x2_extend_low_i32x4_s
        0xc8 => i64x2_extend_high_i32x4_s
        0xc9 => i64x2_extend_low_i32x4_u
        0xca => i64x2_extend_high_i32x4_u
        0xcb => i64x2_shl
        0xcc => i64x2_shr_s
        0xcd => i64x2_shr_u
        0xce => i64x2_add
        0xd1 => i64x2_sub
        0xd5 => i64x2_mul
        0xd6 => i64x2_eq
        0xd7 => i64x2_ne
        0xd8 => i64x2_lt_s
        0xd9 => i64x2_gt_s
        0xda => i64x2_le_s
        0xdb => i64x2_ge_s
        0xdc => i64x2_extmul_low_i32x4_s
        0xdd => i64x2_extmul_high_i32x4_s
        0xde => i64x2_extmul_low_i32x4_u
        0xdf => i64x2_extmul_high_i32x4_u
        0xe0 => f32x4_abs
        0xe1 => f32x4_neg
        0xe3 => f32x4_sqrt
        0xe4 => f32x4_add
        0xe5 => f32x4_sub
        0xe6 => f32x4_mul
        0xe7 => f32x4_div
        0xe8 => f32x4_min
        0xe9 => f32x4_max
        0xea => f32x4_pmin
        0xeb => f32x4_pmax
        0xec => f64x2_abs
        0xed => f64x2_neg
        0xef => f64x2_sqrt
        0xf0 => f64x2_add
        0xf1 => f64x2_sub
        0xf2 => f64x2_mul
        0xf3 => f64x2_div
        0xf4 => f64x2_min
        0xf5 => f64x2_max
        0xf6 => f64x2_pmin
        0xf7 => f64x2_pmax
        0xf8 => i32x4_trunc_sat_f32x4_s
        0xf9 => i32x4_trunc_sat_f32x4_u
        0xfa => f32x4_convert_i32x4_s
        0xfb => f32x4_convert_i32x4_u
        0xfc => i32x4_trunc_sat_f64x2_s_zero
        0xfd => i32x4_trunc_sat_f64x2_u_zero
        0xfe => f64x2_convert_low_i32x4_s
        0xff => f64x2_convert_low_i32x4_u
        n => fail(illegal(s, pos_val, n))
      }
    op_code => fail(illegal(s, pos_val, op_code))
  }
}

///|
pub fn instr_block(s : Stream) -> @list.List[InstrType] raise {
  instr_block_helper(s, @list.empty()).rev()
}

///|
fn instr_block_helper(
  s : Stream,
  acc : @list.List[InstrType],
) -> @list.List[InstrType] raise {
  match peek2(s) {
    None | Some(0x05) | Some(0x0b) => acc
    _ => {
      let e = instr2(s)
      instr_block_helper(s, acc.concat(@list.singleton(e)))
    }
  }
}

///|
pub fn const2(s : Stream) -> @list.List[InstrType] raise {
  let c = at(instr_block, s)
  end2(s)
  c
}

// Sections

///|
pub enum SectionId {
  CustomSection
  TypeSection
  ImportSection
  FuncSection
  TableSection
  MemorySection
  GlobalSection
  ExportSection
  StartSection
  ElemSection
  CodeSection
  DataSection
  DataCountSection
} derive(Eq)

///|
pub fn id(s : Stream) -> SectionId? raise {
  match peek2(s) {
    None => None
    Some(0) => Some(CustomSection)
    Some(1) => Some(TypeSection)
    Some(2) => Some(ImportSection)
    Some(3) => Some(FuncSection)
    Some(4) => Some(TableSection)
    Some(5) => Some(MemorySection)
    Some(6) => Some(GlobalSection)
    Some(7) => Some(ExportSection)
    Some(8) => Some(StartSection)
    Some(9) => Some(ElemSection)
    Some(10) => Some(CodeSection)
    Some(11) => Some(DataSection)
    Some(12) => Some(DataCountSection)
    Some(_) => fail("malformed section id")
  }
}

///|
pub fn[T] section_with_size(
  tag : SectionId,
  f : (Int, Stream) -> T raise,
  default : T,
  s : Stream,
) -> T raise {
  match id(s) {
    Some(tag_found) if tag_found == tag => {
      guard2(fn(s) { skip(1, s) }, s)
      sized(f, s)
    }
    _ => default
  }
}

///|
pub fn[T] section(
  tag : SectionId,
  f : (Stream) -> T raise,
  default : T,
  s : Stream,
) -> T raise {
  section_with_size(tag, fn(_, s) { f(s) }, default, s)
}

// Type section

///|
pub fn type2(s : Stream) -> FuncType raise {
  at(func_type, s)
}

///|
fn type_section(s : Stream) -> @list.List[FuncType] raise {
  section(TypeSection, vec(type2, _), @list.empty(), s)
}

///|
/// Import section
fn import_desc2(s : Stream) -> ImportDesc raise {
  match byte(s) {
    0x00 => FuncImport(at(var2, s))
    0x01 => TableImport(table_type(s))
    0x02 => MemoryImport(memory_type(s))
    0x03 => GlobalImport(global_type(s))
    _ => fail("malformed import kind")
  }
}

///|
fn import2(s : Stream) -> Import raise {
  let module_name = name(s)
  let item_name = name(s)
  let idesc = at(import_desc2, s)
  { module_name, item_name, idesc }
}

///|
fn import_section(s : Stream) -> @list.List[Import] raise {
  let default = @list.default()
  section(ImportSection, vec(import2, _), default, s)
}

///|
/// Function section
fn func_section(s : Stream) -> @list.List[Var] raise {
  let default = @list.default()
  section(FuncSection, vec(var2, _), default, s)
}

///|
/// Table section
fn table2(s : Stream) -> Table raise {
  let ttype = table_type(s)
  { ttype, }
}

///|
fn table_section(s : Stream) -> @list.List[Table] raise {
  let default = @list.default()
  section(TableSection, vec(table2, _), default, s)
}

///|
/// Memory section
fn memory2(s : Stream) -> Memory raise {
  let mtype = memory_type(s)
  { mtype, }
}

///|
fn memory_section(s : Stream) -> @list.List[Memory] raise {
  let default = @list.default()
  section(MemorySection, vec(memory2, _), default, s)
}

///|
/// Global section
fn global2(s : Stream) -> Global raise {
  let gtype = global_type(s)
  let ginit = const2(s)
  { gtype, ginit }
}

///|
fn global_section(s : Stream) -> @list.List[Global] raise {
  let default = @list.default()
  section(GlobalSection, vec(global2, _), default, s)
}

///|
/// Export section
fn export_desc2(s : Stream) -> ExportDesc raise {
  match byte(s) {
    0x00 => FuncExport(var2(s))
    0x01 => TableExport(var2(s))
    0x02 => MemoryExport(var2(s))
    0x03 => GlobalExport(var2(s))
    _ => fail("malformed export kind")
  }
}

///|
fn export(s : Stream) -> Export raise {
  let name = name(s)
  let edesc = export_desc2(s)
  { name, edesc }
}

///|
fn export_section(s : Stream) -> @list.List[Export] raise {
  let default = @list.default()
  section(ExportSection, vec(export, _), default, s)
}

///|
/// Start section
fn start(s : Stream) -> Start raise {
  let sfunc = var2(s)
  { sfunc, }
}

///|
fn start_section(s : Stream) -> Start? raise {
  section(StartSection, opt2(start, true, _), None, s)
}

///|
/// Code section
fn local2(s : Stream) -> (Int, ValueType) raise {
  let n = u32(s)
  let t = value_type(s)
  (n, t)
}

///|
fn locals2(s : Stream) -> @list.List[ValueType] raise {
  let start_pos = pos(s)
  let nts = vec(local2, s)
  let ns = nts.map(n => n.0.to_int64())
  let total_locals = ns.fold(init=0L, (sum, elem) => sum + elem)
  require2(total_locals < 0x1_0000_0000L, s, start_pos, "too many locals")
  nts.flat_map(nt => @list.from_array(Array::make(nt.0, nt.1)))
}

///|
fn code(_ : Int, s : Stream) -> Func raise {
  let locals = locals2(s)
  let body = instr_block(s)
  end2(s)
  { locals, body, ftype: -1 }
}

///|
fn code_section(s : Stream) -> @list.List[Func] raise {
  let default = @list.default()
  section(CodeSection, vec(fn(_) { sized(code, s) }, _), default, s)
}

///|
/// Element section
fn passive(s : Stream) -> SegmentMode {
  Passive
}

///|
fn active(s : Stream) -> SegmentMode raise {
  let index = var2(s)
  let offset = const2(s)
  Active({ index, offset })
}

///|
fn active_zero(s : Stream) -> SegmentMode raise {
  let index = 0
  let offset = const2(s)
  Active({ index, offset })
}

///|
fn declarative(s : Stream) -> SegmentMode {
  Declarative
}

///|
fn elem_index(s : Stream) -> @list.List[Instr] raise {
  let x = var2(s)
  @list.singleton(ref_func(x))
}

///|
fn elem_kind(s : Stream) -> RefType raise {
  match byte(s) {
    0x00 => FuncRefType
    _ => fail("malformed element kind")
  }
}

///|
fn elem2(s : Stream) -> ElemSegment raise {
  match u32(s) {
    0x00 => {
      let emode = active_zero(s)
      let einit = vec(elem_index, s)
      { etype: FuncRefType, einit, emode }
    }
    0x01 => {
      let emode = passive(s)
      let etype = elem_kind(s)
      let einit = vec(elem_index, s)
      { etype, einit, emode }
    }
    0x02 => {
      let emode = active(s)
      let etype = elem_kind(s)
      let einit = vec(elem_index, s)
      { etype, einit, emode }
    }
    0x03 => {
      let emode = declarative(s)
      let etype = elem_kind(s)
      let einit = vec(elem_index, s)
      { etype, einit, emode }
    }
    0x04 => {
      let emode = active_zero(s)
      let einit = vec(const2, s)
      { etype: FuncRefType, einit, emode }
    }
    0x05 => {
      let emode = passive(s)
      let etype = ref_type(s)
      let einit = vec(const2, s)
      { etype, einit, emode }
    }
    0x06 => {
      let emode = active(s)
      let etype = ref_type(s)
      let einit = vec(const2, s)
      { etype, einit, emode }
    }
    0x07 => {
      let emode = declarative(s)
      let etype = ref_type(s)
      let einit = vec(const2, s)
      { etype, einit, emode }
    }
    _ => fail("malformed elements segment kind")
  }
}

///|
fn elem_section(s : Stream) -> @list.List[ElemSegment] raise {
  section(ElemSection, vec(elem2, _), @list.empty(), s)
}

///|
/// Data section
fn data2(s : Stream) -> DataSegment raise {
  match u32(s) {
    0x00 => {
      let dmode = active_zero(s)
      let dinit = string(s)
      { dinit, dmode }
    }
    0x01 => {
      let dmode = passive(s)
      let dinit = string(s)
      { dinit, dmode }
    }
    0x02 => {
      let dmode = active(s)
      let dinit = string(s)
      { dinit, dmode }
    }
    _ => fail("malformed data segment kind")
  }
}

///|
fn data_section(s : Stream) -> @list.List[DataSegment] raise {
  section(DataSection, vec(data2, _), @list.empty(), s)
}

///|
/// DataCount section
fn data_count(s : Stream) -> Int? raise {
  Some(u32(s))
}

///|
fn data_count_section(s : Stream) -> Int? raise {
  section(DataCountSection, data_count, None, s)
}

///|
/// Custom section
fn custom(size : Int, s : Stream) -> (Bytes, Bytes)? raise {
  let start = pos(s)
  let id = name(s)
  let bs = get_string(size - (pos(s) - start), s)
  Some((id, bs))
}

///|
fn custom_section(s : Stream) -> (Bytes, Bytes)? raise {
  section_with_size(CustomSection, custom, None, s)
}

///|
fn non_custom_section(s : Stream) -> Unit? raise {
  match id(s) {
    None | Some(CustomSection) => None
    _ => {
      skip(1, s)
      let _ = sized(skip, s)
      Some(())
    }
  }
}

///|
/// Modules
fn[A, B] iterate(f : (A) -> B? raise, s : A) -> Unit raise {
  loop f(s) {
    None => break
    _ => continue f(s)
  }
}

///|
let magic = 0x6d736100

///|
fn module_2(s : Stream) -> Module_ raise {
  let header = word32(s)
  require2(header == magic, s, 0, "magic header not detected")
  let version = word32(s)
  require2(version == 1, s, 4, "unknown binary version")
  iterate(custom_section, s)
  let types = type_section(s)
  iterate(custom_section, s)
  let imports = import_section(s)
  iterate(custom_section, s)
  let func_types = func_section(s)
  iterate(custom_section, s)
  let tables = table_section(s)
  iterate(custom_section, s)
  let memories = memory_section(s)
  iterate(custom_section, s)
  let globals = global_section(s)
  iterate(custom_section, s)
  let exports = export_section(s)
  iterate(custom_section, s)
  let start = start_section(s)
  iterate(custom_section, s)
  let elems = elem_section(s)
  iterate(custom_section, s)
  let data_count = data_count_section(s)
  iterate(custom_section, s)
  let func_bodies = code_section(s)
  iterate(custom_section, s)
  let datas = data_section(s)
  iterate(custom_section, s)
  require2(pos(s) == len(s), s, len(s), "unexpected content after last section")
  require2(
    func_types.length() == func_bodies.length(),
    s,
    len(s),
    "function and code section have inconsistent lengths",
  )
  let data_length = datas.length()
  match data_count {
    None => ()
    Some(count) =>
      require2(
        count == data_length,
        s,
        len(s),
        "data count and data section have inconsistent lengths",
      )
  }
  let mut funcs = @list.new()
  func_bodies
  .iter2()
  .each((i, func_body) => {
    let func = { ..func_body, ftype: func_types.unsafe_nth(i) }
    funcs = funcs.prepend(func)
  })
  {
    types,
    tables,
    memories,
    globals,
    funcs,
    imports,
    exports,
    elems,
    datas,
    start,
  }
}

///|
fn decode(name : Bytes, bs : Bytes) -> Module_ raise {
  at(module_2, stream(name, bs))
}

///|
fn all_custom(tag : Bytes, name : Bytes, bs : Bytes) -> @list.List[Bytes] raise {
  let s = stream(name, bs)
  let header = word32(s)
  require2(header == magic, s, 0, "magic header not detected")
  let version = word32(s)
  require2(version == 1, s, 4, "unknown binary version")
  fn collect() -> @list.List[Bytes] raise {
    iterate(non_custom_section, s)
    match custom_section(s) {
      None => @list.empty()
      Some((n, bs)) => if n == tag { collect().prepend(bs) } else { collect() }
    }
  }

  collect()
}

///|
fn decode_custom(
  tag : Bytes,
  name : Bytes,
  bs : Bytes,
) -> @list.List[Bytes] raise {
  all_custom(tag, name, bs)
}

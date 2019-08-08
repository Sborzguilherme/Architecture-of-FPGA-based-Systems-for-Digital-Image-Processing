library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Package_Fixed is

-- Components instantiation
  ---------------- Size Constants -------------
  constant MSB : integer := 8;
  constant LSB : integer := 8;
--------------------- Type declaration --------------------
  subtype fixed is std_logic_vector(MSB+LSB-1 downto 0);  -- Fixed-point type
  type fixed_vector is array(natural range <>) of fixed;  -- Array of fixed-point values
  type addr_vector is array(natural range <>) of std_logic_vector(7 downto 0);
  -------------------- Functions -----------------
  function to_fixed(I : integer) return fixed;
  function "*" (A : fixed; B : fixed) return fixed;
  function "+" (A : fixed; B : fixed) return fixed;
  function "<" (A : fixed; B : fixed) return boolean;
  function "<=" (A : fixed; B : fixed) return boolean;
  function ">" (A : fixed; B : fixed) return boolean;
  function ">=" (A : fixed; B : fixed) return boolean;
  function shift_left (A : fixed; QT : integer) return fixed;
  function shift_right (A : fixed; QT : integer) return fixed;

  ----------------- Constants -------------
  constant S_MAXVALUE : fixed := (others=>'1');  -- There is no negative values
  constant S_MINVALUE : fixed := (others=>'0');
end Package_Fixed;

package body Package_Fixed is

  ---- converts integer without decimal part to fixed
  function to_fixed (I : integer) return fixed is
  begin
    return fixed(shift_left(to_unsigned(I, MSB+LSB), LSB));
  end function;

  ----PERFORMS A FIXED POINT MULTIPLICATION
  function "*" (A : fixed; B : fixed) return fixed is
    variable v_MULT    : unsigned(2*(MSB+LSB)-1 downto 0);
    variable v_RESULT  : unsigned(2*(MSB+LSB)-1 downto 0);
  begin
    v_MULT := unsigned(A) * unsigned(B);
    v_RESULT := shift_right(v_MULT, LSB);
    return fixed(resize(v_RESULT, MSB+LSB));
  end function;

  -- SUM FUNCTION WITHOUT OVERFLOW VERIFICATION
    function "+" (A : fixed; B : fixed) return fixed is
      variable v_SUM : unsigned(MSB+LSB downto 0);
    begin
      v_SUM := resize(unsigned(A), MSB+LSB+1) + resize(unsigned(B), MSB+LSB+1);
      return fixed(resize(v_SUM, MSB+LSB));
    end function;

    function "<" (A : fixed; B : fixed) return boolean is
    begin
      return (unsigned(A) < unsigned(B));
    end function;

    function "<=" (A : fixed; B : fixed) return boolean is
    begin
      return (unsigned(A) <= unsigned(B));
    end function;

    function ">" (A : fixed; B : fixed) return boolean is
    begin
      return (unsigned(A) > unsigned(B));
    end function;

    function ">=" (A : fixed; B : fixed) return boolean is
    begin
      return (unsigned(A) >= unsigned(B));
    end function;

    function shift_left (A : fixed; QT : integer) return fixed is
     begin
       return fixed(shift_left(unsigned(A), QT));
     end function;

     function shift_right (A : fixed; QT : integer) return fixed is
     begin
       return fixed(shift_right(unsigned(A), QT));
     end function;

end Package_Fixed;

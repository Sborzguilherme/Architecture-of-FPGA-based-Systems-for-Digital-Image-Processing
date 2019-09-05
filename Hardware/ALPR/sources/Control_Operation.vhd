-----------------------------------------------------------------
-- Project: ALPR
-- Author:  Guilherme Sborz
-- Date:    13/12/2018
-- File:    Control_Operation.vhd

-- FSM that controls the Morphological opening 1

-- states:
-- s_IDLE: Start state where the counters are drained
-- s_BUF_FIL: stay in this state until the delay row arch is not fullfilled
-- s_REG_STG_0_DELAY: Generate a delay to store the pixels selected from stage 0 in the operation_MO1_stages block
-- s_REG_STG_1_DELAY: Generate a delay to store the pixels selected from stage 1 in the operation_MO1_stages block
-- s_VAL_WIN: in this state valid pixel are generated (saves in RAM or drived to output)
-- s_INV_WIN: state where the kernel in the DRA is not valid. The pixel from input keep being saved in the DRA, but valid pixels are not generated
-- s_END_FIRST_OP: this state indicates that the one operation has ended and decide if the fsm can go to final state or not
-- s_CHANGE_OP: state where the fsm goes when the first operation ends. The register that indicates the current operation change value (0 to 1)
-- s_END: Final state. Indicate that the both erode and dilation operation have ended. The FSM can be locked in this state (for Modelsim test purposals) or goes to the s_IDLE state (to restart the block and make it ready for other image)
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALPR_package.all;

entity Control_Operation is
  port (
    i_CLK             : in  std_logic;
    i_RST             : in  std_logic;
    i_START           : in  std_logic;
    i_VALID_PIXEL     : in  std_logic;
    i_BUFFERS_FILLED  : in  std_logic;
    i_MAX_KER_TOT	    : in  std_logic;
    i_MAX_KER_ROW		  : in  std_logic;
    i_MAX_INV_KER		  : in  std_logic;
    o_ENA_CNT_KER_TOT	: out std_logic;
    o_CLR_CNT_KER_TOT	: out std_logic;
	  o_ENA_CNT_KER_ROW	: out std_logic;
	  o_CLR_CNT_KER_ROW	: out std_logic;
	  o_ENA_CNT_INV_KER : out std_logic;
	  o_CLR_CNT_INV_KER	: out std_logic;
	  o_ENA_CNT_BUF_FIL	: out std_logic;
	  o_CLR_CNT_BUF_FIL	: out std_logic;
	  o_ENA_WRI_KER		  : out std_logic;
    o_PIX_RDY			    : out std_logic;
    o_DONE            : out std_logic
  );
end Control_Operation;

architecture first_op of Control_Operation is
  type state_type is (
    s_IDLE,
    s_BUF_FIL,
    s_REG_STG_0_DELAY, -- 1st stage pipeline in Max_Min_19 block
    s_REG_STG_1_DELAY, -- 2nd stage pipeline in Max_Min_19 block
    s_VAL_WIN,
    s_INV_WIN,
    s_SEC_OP_END,
    s_SEC_OP_DELAY_0, -- State needed to generate the last pixel in the second operation
    s_SEC_OP_DELAY_1,
    s_SEC_OP_DELAY_2,
    s_END
);
  signal r_state_reg : state_type;
  signal r_next_state : state_type;

begin
  p_state_reg : process (i_CLK, i_RST)
  begin
    if (i_RST = '1') then
      r_state_reg <= s_IDLE; -- idle
  elsif (rising_edge(i_CLK)) then
      r_state_reg <= r_next_state;
    end if;
  end process;

  p_next_state : process (r_state_reg, i_START, i_BUFFERS_FILLED, i_MAX_KER_TOT, i_MAX_KER_ROW, i_MAX_INV_KER)
  begin
    case (r_state_reg) is
      when s_IDLE =>
        if(i_START = '1') then
          r_next_state <= s_BUF_FIL;
        else
          r_next_state <= s_IDLE;
        end if;

      when s_BUF_FIL =>
        if (i_BUFFERS_FILLED = '1') then
          r_next_state <= s_REG_STG_0_DELAY;
          --r_next_state <= s_VAL_WIN;
        else
          r_next_state <= s_BUF_FIL;
        end if;

      when s_REG_STG_0_DELAY =>
        r_next_state <= s_REG_STG_1_DELAY;

      when s_REG_STG_1_DELAY =>
           r_next_state <= s_VAL_WIN;

      when s_VAL_WIN =>
        if(i_MAX_KER_TOT = '1') then
          r_next_state <= s_SEC_OP_END;
        elsif (i_MAX_KER_ROW = '1') then
          r_next_state <= s_INV_WIN;
        else
          r_next_state <= s_VAL_WIN;
        end if;

      when s_INV_WIN =>
        if (i_MAX_KER_TOT = '1') then
            r_next_state <= s_SEC_OP_END;
        elsif(i_MAX_INV_KER = '1')then
          r_next_state <= s_VAL_WIN;
        else
          r_next_state <= s_INV_WIN;
        end if;

-- Extra state needed to synchronization
      when s_SEC_OP_END =>
        r_next_state <= s_SEC_OP_DELAY_0;

-- Extra state to add delay needed to process second operation
      when s_SEC_OP_DELAY_0 =>
        r_next_state <= s_SEC_OP_DELAY_1;

      when s_SEC_OP_DELAY_1 =>
        r_next_state <= s_SEC_OP_DELAY_2;

      when s_SEC_OP_DELAY_2 =>
        r_next_state <= s_END;

      when s_END =>
        r_next_state <= s_END;

    end case;
  end process;


 o_ENA_CNT_KER_TOT  <= '1' when r_state_reg = s_VAL_WIN    else '0';

 o_CLR_CNT_KER_TOT  <= '1' when r_state_reg = s_IDLE       else '0';

 o_ENA_CNT_KER_ROW  <= '1' when r_state_reg = s_VAL_WIN    else '0';

 o_CLR_CNT_KER_ROW  <= '1' when r_state_reg = s_IDLE or
                                r_state_reg = s_INV_WIN    else '0';

 o_ENA_CNT_INV_KER  <= '1' when r_state_reg = s_INV_WIN    else '0';

 o_CLR_CNT_INV_KER  <= '1' when r_state_reg = s_VAL_WIN    else '0';

 o_ENA_CNT_BUF_FIL  <= '1' when r_state_reg = s_BUF_FIL    else '0';

 o_CLR_CNT_BUF_FIL  <= '1' when r_state_reg = s_IDLE       else '0';

 o_ENA_WRI_KER		<= '1' when r_state_reg = s_BUF_FIL         or
                              r_state_reg = s_REG_STG_0_DELAY or
                              r_state_reg = s_REG_STG_1_DELAY or
                              r_state_reg = s_VAL_WIN         or
                              r_state_reg = s_INV_WIN         else '0';

 o_PIX_RDY          <= '1' when r_state_reg = s_VAL_WIN or
                                r_state_reg = s_SEC_OP_DELAY_0 or
                                r_state_reg = s_SEC_OP_DELAY_1 or
                                r_state_reg = s_SEC_OP_DELAY_2 or
                                r_state_reg = s_SEC_OP_END     else '0';

 o_DONE             <= '1' when r_state_reg = s_END        else '0';

end first_op;

architecture second_op of Control_Operation is
  type state_type is (
    s_IDLE,
    s_BUF_FIL,
    s_REG_STG_0_DELAY,
    s_REG_STG_1_DELAY,
    s_VAL_WIN,
    s_INV_WIN,
    s_END
);
  signal r_state_reg : state_type;
  signal r_next_state : state_type;

begin
  p_state_reg : process (i_CLK, i_RST)
  begin
    if (i_RST = '1') then
      r_state_reg <= s_IDLE; -- idle
  elsif (rising_edge(i_CLK)) then
      r_state_reg <= r_next_state;
    end if;
  end process;

  p_next_state : process (r_state_reg, i_START, i_VALID_PIXEL, i_BUFFERS_FILLED, i_MAX_KER_TOT, i_MAX_KER_ROW, i_MAX_INV_KER)
  begin
    case (r_state_reg) is
      when s_IDLE =>
        if(i_START = '1') then
          r_next_state <= s_BUF_FIL;
        else
          r_next_state <= s_IDLE;
        end if;

      when s_BUF_FIL =>
        -- if (i_VALID_PIXEL = '0') then
        --     r_next_state <= s_STALL_BUF_FIL;
        if (i_BUFFERS_FILLED = '1') then
            r_next_state <= s_REG_STG_0_DELAY;
            --r_next_state <= s_VAL_WIN;
        else
            r_next_state <= s_BUF_FIL;
        end if;

      -- when s_STALL_BUF_FIL =>
      --   if (i_VALID_PIXEL = '1') then
      --       r_next_state <= s_BUF_FIL;
      --   else
      --       r_next_state <= s_STALL_BUF_FIL;
      --   end if;

      when s_REG_STG_0_DELAY =>
        r_next_state <= s_REG_STG_1_DELAY;

     when s_REG_STG_1_DELAY =>
          r_next_state <= s_VAL_WIN;

      when s_VAL_WIN =>
        --if(i_VALID_PIXEL = '0') then
        --    r_next_state <= s_STALL_VAL_WIN;
        if(i_MAX_KER_TOT = '1') then
          r_next_state <= s_END;
        elsif (i_MAX_KER_ROW = '1') then
          r_next_state <= s_INV_WIN;
        else
          r_next_state <= s_VAL_WIN;
        end if;
     --
      -- when s_STALL_VAL_WIN =>
      --   if (i_VALID_PIXEL = '1') then
      --       r_next_state <= s_VAL_WIN;
      --   else
      --       r_next_state <= s_STALL_VAL_WIN;
      --   end if;
     --
      when s_INV_WIN =>
        --if(i_VALID_PIXEL = '0') then
        --    r_next_state <= s_STALL_INV_WIN;
        if (i_MAX_KER_TOT = '1') then
            r_next_state <= s_END;
        elsif(i_MAX_INV_KER = '1') then
          r_next_state <= s_VAL_WIN;
        else
          r_next_state <= s_INV_WIN;
        end if;
     --
        -- when s_STALL_INV_WIN =>
        --     if(i_VALID_PIXEL = '1') then
        --         r_next_state <= s_INV_WIN;
        --     else
        --         r_next_state <= s_STALL_INV_WIN;
        --     end if;

      when s_END =>
        r_next_state <= s_END;

    end case;
  end process;


 o_ENA_CNT_KER_TOT  <= '1' when r_state_reg = s_VAL_WIN    else '0';

 o_CLR_CNT_KER_TOT  <= '1' when r_state_reg = s_IDLE       else '0';

 o_ENA_CNT_KER_ROW  <= '1' when r_state_reg = s_VAL_WIN    else '0';

 o_CLR_CNT_KER_ROW  <= '1' when r_state_reg = s_IDLE or
                                r_state_reg = s_INV_WIN    else '0';

 o_ENA_CNT_INV_KER  <= '1' when r_state_reg = s_INV_WIN    else '0';

 o_CLR_CNT_INV_KER  <= '1' when r_state_reg = s_VAL_WIN    else '0';

 o_ENA_CNT_BUF_FIL  <= '1' when r_state_reg = s_BUF_FIL    else '0';

 o_CLR_CNT_BUF_FIL  <= '1' when r_state_reg = s_IDLE       else '0';

 o_ENA_WRI_KER		<= '1' when r_state_reg = s_BUF_FIL         or
                              r_state_reg = s_REG_STG_0_DELAY or
                              r_state_reg = s_REG_STG_1_DELAY or
                              r_state_reg = s_VAL_WIN         or
                              r_state_reg = s_INV_WIN         else '0';

 o_PIX_RDY          <= '1' when r_state_reg = s_VAL_WIN    else '0';

 o_DONE             <= '1' when r_state_reg = s_END        else '0';

end second_op;

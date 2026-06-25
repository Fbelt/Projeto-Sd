`timescale 1ns/1ps

module safecrack_pro_tb;

    reg        CLOCK_50;
    reg  [3:0] KEY;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4;
    wire [8:0] LEDG;
    wire [17:0] LEDR;

    safecrack_pro dut (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .LEDG(LEDG),
        .LEDR(LEDR)
    );

    initial CLOCK_50 = 0;
    always  #10 CLOCK_50 = ~CLOCK_50;

    initial KEY = 4'b1111;

    task pressiona;
        input integer btn;
        begin
            KEY[btn] = 0;
            #22_000_000;
            KEY[btn] = 1;
            #5_000_000;
        end
    endtask

    task espera_com_timeout;
        input [63:0] ciclos_max;
        input [0:0]  condicao;
    endtask

    integer timeout;

    initial begin
        #100;
        $display("=== TESTE 1: reset inicial ===");
        pressiona(0);
        #100;
        $display("HEX3 = %b | esperado 1000000 (digito 0)", HEX3);
        $display("HEX4 = %b | esperado 1111001 (posicao 0)", HEX4);

        $display("=== TESTE 2: senha correta 1-2-3-4 ===");
        pressiona(2);
        $display("digito0 incrementado: HEX3 = %b | esperado 1111001 (1)", HEX3);
        pressiona(1);
        pressiona(2); pressiona(2);
        $display("digito1 incrementado: HEX2 = %b | esperado 0100100 (2)", HEX2);
        pressiona(1);
        pressiona(2); pressiona(2); pressiona(2);
        $display("digito2 incrementado: HEX1 = %b | esperado 0110000 (3)", HEX1);
        pressiona(1);
        pressiona(2); pressiona(2); pressiona(2); pressiona(2);
        $display("digito3 incrementado: HEX0 = %b | esperado 0011001 (4)", HEX0);
        pressiona(1);

        #100;
        if (LEDG == 9'b111111111)
            $display("PASSOU: leds verdes acenderam (ACERTO)");
        else
            $display("FALHOU: leds verdes nao acenderam | LEDG = %b", LEDG);

        timeout = 0;
        while (LEDG != 0 && timeout < 300_000_000) begin
            @(posedge CLOCK_50);
            timeout = timeout + 1;
        end
        if (timeout >= 300_000_000)
            $display("FALHOU: timeout - nao saiu do estado ACERTO");
        else
            $display("PASSOU: voltou ao inicio apos ~5s (timeout = %0d ciclos)", timeout);

        $display("=== TESTE 3: senha errada 0-0-0-0 ===");
        pressiona(1); pressiona(1); pressiona(1); pressiona(1);
        #100;
        if (LEDR == 18'b111111111111111111)
            $display("PASSOU: leds vermelhos acenderam (ERRO)");
        else
            $display("FALHOU: leds vermelhos nao acenderam | LEDR = %b", LEDR);

        timeout = 0;
        while (LEDR != 0 && timeout < 200_000_000) begin
            @(posedge CLOCK_50);
            timeout = timeout + 1;
        end
        if (timeout >= 200_000_000)
            $display("FALHOU: timeout - nao saiu do estado ERRO");
        else
            $display("PASSOU: voltou ao inicio apos ~3s (timeout = %0d ciclos)", timeout);

        $display("=== TESTE 4: wrap-around ===");
        pressiona(3);
        #100;
        if (HEX3 == 7'b0010000) $display("PASSOU: HEX3 = %b (9)", HEX3);
        else $display("FALHOU: HEX3 = %b | esperado 0010000 (9)", HEX3);
        pressiona(2);
        #100;
        if (HEX3 == 7'b1000000) $display("PASSOU: wrap para cima ok, HEX3 = %b (0)", HEX3);
        else $display("FALHOU: HEX3 = %b | esperado 1000000 (0)", HEX3);

        $display("=== TESTE 5: reset no meio da digitacao ===");
        pressiona(2); pressiona(2); pressiona(2);
        pressiona(1);
        pressiona(2); pressiona(2);
        pressiona(0);
        #100;
        if (HEX3 == 7'b1000000 && HEX4 == 7'b1111001)
            $display("PASSOU: reset ok - HEX3=%b(0) HEX4=%b(pos 0)", HEX3, HEX4);
        else
            $display("FALHOU: HEX3=%b HEX4=%b", HEX3, HEX4);

        $display("=== simulacao concluida ===");
        $finish;
    end

endmodule

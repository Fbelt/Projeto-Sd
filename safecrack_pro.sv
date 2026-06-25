// SafeCrack Pro - Projeto Final SD 2026.1
// Grupo: Felipe Belfort, Gabriel Costa, Gabriel Geller, Lucas Procopio, Pedro Henrique Reynaldo

module safecrack_pro (
    input CLOCK_50,
    input [3:0] KEY,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output reg [6:0] HEX4,
    output [8:0] LEDG,
    output [17:0] LEDR
);

parameter S0 = 4'd1;
parameter S1 = 4'd2;
parameter S2 = 4'd3;
parameter S3 = 4'd4;

parameter DIGITO0 = 3'd0;
parameter DIGITO1 = 3'd1;
parameter DIGITO2 = 3'd2;
parameter DIGITO3 = 3'd3;
parameter ACERTO = 3'd4;
parameter ERRO = 3'd5;

reg [2:0] estado;
reg [2:0] prox_estado;

reg [3:0] digito0, digito1, digito2, digito3;

reg [19:0] cnt0, cnt1, cnt2, cnt3;
reg estavel0, estavel1, estavel2, estavel3;
reg prev0, prev1, prev2, prev3;
wire pulso0, pulso1, pulso2, pulso3;

reg [27:0] timer;

always @(posedge CLOCK_50) begin
    if (!KEY[0]) begin
        if (cnt0 < 20'd1000000)
            cnt0 <= cnt0 + 1;
        else
            estavel0 <= 1;
    end else begin
        cnt0 <= 0;
        estavel0 <= 0;
    end
    prev0 <= estavel0;
end
assign pulso0 = estavel0 & ~prev0;

always @(posedge CLOCK_50) begin
    if (!KEY[1]) begin
        if (cnt1 < 20'd1000000)
            cnt1 <= cnt1 + 1;
        else
            estavel1 <= 1;
    end else begin
        cnt1 <= 0;
        estavel1 <= 0;
    end
    prev1 <= estavel1;
end
assign pulso1 = estavel1 & ~prev1;

always @(posedge CLOCK_50) begin
    if (!KEY[2]) begin
        if (cnt2 < 20'd1000000)
            cnt2 <= cnt2 + 1;
        else
            estavel2 <= 1;
    end else begin
        cnt2 <= 0;
        estavel2 <= 0;
    end
    prev2 <= estavel2;
end
assign pulso2 = estavel2 & ~prev2;

always @(posedge CLOCK_50) begin
    if (!KEY[3]) begin
        if (cnt3 < 20'd1000000)
            cnt3 <= cnt3 + 1;
        else
            estavel3 <= 1;
    end else begin
        cnt3 <= 0;
        estavel3 <= 0;
    end
    prev3 <= estavel3;
end
assign pulso3 = estavel3 & ~prev3;

wire senha_correta;
assign senha_correta = (digito0 == S0) && (digito1 == S1) &&
                       (digito2 == S2) && (digito3 == S3);

always @(*) begin
    prox_estado = estado;
    case (estado)
        DIGITO0: begin
            if (pulso0) prox_estado = DIGITO0;
            else if (pulso1) prox_estado = DIGITO1;
        end
        DIGITO1: begin
            if (pulso0) prox_estado = DIGITO0;
            else if (pulso1) prox_estado = DIGITO2;
        end
        DIGITO2: begin
            if (pulso0) prox_estado = DIGITO0;
            else if (pulso1) prox_estado = DIGITO3;
        end
        DIGITO3: begin
            if (pulso0) prox_estado = DIGITO0;
            else if (pulso1) begin
                if (senha_correta)
                    prox_estado = ACERTO;
                else
                    prox_estado = ERRO;
            end
        end
        ACERTO: begin
            if (pulso0 || (timer >= 28'd250000000))
                prox_estado = DIGITO0;
        end
        ERRO: begin
            if (pulso0 || (timer >= 28'd150000000))
                prox_estado = DIGITO0;
        end
        default: prox_estado = DIGITO0;
    endcase
end

always @(posedge CLOCK_50) begin
    estado <= prox_estado;

    if (pulso0 || ((estado == ACERTO || estado == ERRO) && prox_estado == DIGITO0)) begin
        digito0 <= 0;
        digito1 <= 0;
        digito2 <= 0;
        digito3 <= 0;
    end else begin
        case (estado)
            DIGITO0: begin
                if (pulso2) digito0 <= (digito0 == 9) ? 0 : digito0 + 1;
                else if (pulso3) digito0 <= (digito0 == 0) ? 9 : digito0 - 1;
            end
            DIGITO1: begin
                if (pulso2) digito1 <= (digito1 == 9) ? 0 : digito1 + 1;
                else if (pulso3) digito1 <= (digito1 == 0) ? 9 : digito1 - 1;
            end
            DIGITO2: begin
                if (pulso2) digito2 <= (digito2 == 9) ? 0 : digito2 + 1;
                else if (pulso3) digito2 <= (digito2 == 0) ? 9 : digito2 - 1;
            end
            DIGITO3: begin
                if (pulso2) digito3 <= (digito3 == 9) ? 0 : digito3 + 1;
                else if (pulso3) digito3 <= (digito3 == 0) ? 9 : digito3 - 1;
            end
        endcase
    end
end

always @(posedge CLOCK_50) begin
    if (estado == DIGITO0 || estado == DIGITO1 ||
        estado == DIGITO2 || estado == DIGITO3)
        timer <= 0;
    else
        timer <= timer + 1;
end

assign LEDG = (estado == ACERTO) ? 9'b111111111 : 9'b0;
assign LEDR = (estado == ERRO)   ? 18'b111111111111111111 : 18'b0;

function [6:0] seg7;
    input [3:0] d;
    case (d)
        4'd0: seg7 = 7'b1000000;
        4'd1: seg7 = 7'b1111001;
        4'd2: seg7 = 7'b0100100;
        4'd3: seg7 = 7'b0110000;
        4'd4: seg7 = 7'b0011001;
        4'd5: seg7 = 7'b0010010;
        4'd6: seg7 = 7'b0000010;
        4'd7: seg7 = 7'b1111000;
        4'd8: seg7 = 7'b0000000;
        4'd9: seg7 = 7'b0010000;
        default: seg7 = 7'b1111111;
    endcase
endfunction

assign HEX3 = seg7(digito0);
assign HEX2 = seg7(digito1);
assign HEX1 = seg7(digito2);
assign HEX0 = seg7(digito3);

always @(*) begin
    if (estado == ACERTO || estado == ERRO)
        HEX4 = 7'b1111111;
    else begin
        case (estado)
            DIGITO0: HEX4 = seg7(4'd0);
            DIGITO1: HEX4 = seg7(4'd1);
            DIGITO2: HEX4 = seg7(4'd2);
            DIGITO3: HEX4 = seg7(4'd3);
            default: HEX4 = 7'b1111111;
        endcase
    end
end

endmodule

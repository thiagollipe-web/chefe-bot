{
------------ PROJETO GENESIS --------------
Autor : Marcos Romero (RH Games - Beljogos)
Email : romero1978@gmail.com
Página: http://romerogames.blogspot.com
-------------------------------------------
}

program MINA2;
uses crt,dos;

const CI1 = 327;     {setas}
      BA1 = 335;
      ES1 = 330;
      DI1 = 332;
      CI2 = 87;      {w, a, s, d}
      BA2 = 83;
      ES2 = 65;
      DI2 = 68;
      PA  = 80;
      ESC = 27;
      ENT = 13;
      QM  = 5;  {qt de minas}
      QF  = 5;  {qt de fases}
      altura  = 17;
      largura = 50;
      diflin = 6;
      difcol = 15;

type
     geral = record
              col,lin,cara,cor,direcao:integer;
             end;
     tiporecorde = record
                      nome:string[10];
                      score:integer;
                   end;

var
     mina: array[1..QM] of geral;
     bola: array[1..8] of geral;
     jog,obj: array[1..2] of geral;
     extrainfo: array[1..2] of tiporecorde;
     recordes: array[1..QF] of tiporecorde;
     mapa: array[1..altura,1..largura] of integer;
     frec: file of tiporecorde;
     i,j,qjog,qbola,vel,fase,espera,tecla,cont: integer;
     sair,pontoobj,tempo: integer;

procedure escondecursor;
 begin
   gotoxy(40,25);
   textcolor(0);
   textbackground(0);
   write(' ');
   gotoxy(40,25);
 end;

procedure msg(txt:string);
begin
  gotoxy(30,5);
  textcolor(15);
  write(txt);
  escondecursor;
end;

procedure apaga(lin,col:integer);
begin
  gotoxy(col+difcol,lin+diflin);
  write(' ');
end;

procedure apagalinha(linha:integer);
 var ind,max:integer;
 begin
   if linha = 25 then max :=79
   else max :=80;
   for ind:=1 to max do
       begin
         gotoxy(ind,linha);
         write(' ');
       end;
 end;

procedure apagatela;
var ind:integer;
 begin
   textcolor(15);
   textbackground(0);
   for ind:=1 to 13 do
    begin
      apagalinha(ind);
      apagalinha(26-ind);
      escondecursor;
      textcolor(15);
      textbackground(0);
      delay(40);
    end;
 end;

procedure inicia(var nlin,ncol:integer);
begin
   repeat
     nlin:=random(altura)+1;
     ncol:=random(largura)+1;
   until mapa[nlin,ncol]=0;
end;

procedure morte(x:integer);
begin
  apagalinha(5);
  sound(50);
  textcolor(jog[x].cor);
  gotoxy(jog[x].col+difcol,jog[x].lin+diflin);
  write('*');
  msg(extrainfo[x].nome+' explodiu.');
  delay(300);
  nosound;
  delay(400);
  apagalinha(5);
  extrainfo[x].score:=extrainfo[x].score-5;
  jog[x].direcao:=0;
end;

procedure mostra;
var ind:integer;
begin
  for ind:=1 to qjog do
    begin
      textcolor(jog[ind].cor);
      gotoxy(obj[ind].col+difcol,obj[ind].lin+diflin);
      write(chr(obj[ind].cara));
      gotoxy(jog[ind].col+difcol,jog[ind].lin+diflin);
      write(chr(jog[ind].cara));
    end;
  if qbola > 0 then
   for ind:= 1 to qbola do
    begin
      textcolor(15);{bola[ind].cor);}
      gotoxy(bola[ind].col+difcol,bola[ind].lin+diflin);
      write('0'); {chr(bola[ind].cara));}
    end;
end;

procedure enfeite;
 var asteriscos:string;
     a,b,c:integer;

 begin
      asteriscos:='*    *    *    *    *    *    *    *    *    *    *    *    *    *    *    *    *    ';
      textcolor(11);
      textbackground(0);
      repeat
            for a:=1 to 5 do
             begin
                  gotoxy(1,1);
                  write(copy(asteriscos,a,80));
                  gotoxy(1,22);
                  write(copy(asteriscos,6-a,80));
                  escondecursor;
                  textcolor(11);
                  textbackground(0);
                  delay(60);
                  for b:=2 to 21 do
                   begin
                     c:=(a+b) mod 5;
                     if c = 1 then
                      begin
                        gotoxy(80,b);
                        write('*');
                        gotoxy(1,23-b);
                        write('*');
                      end
                     else
                      begin
                        gotoxy(80,b);
                        write(' ');
                        gotoxy(1,23-b);
                        write(' ');
                      end;
                   end;
             end;
      until keypressed;
 end;


procedure instrucoes;
 var tecla_res:integer;
 begin
   apagatela;
   textcolor(14);
   textbackground(0);
   gotoxy(1,2);
   writeln('                            INSTRUCOES  ');
   writeln('    MINA 2 eh um jogo para um ou dois jogadores. O seu objetivo eh pegar ');
   writeln('  o maximo de objetos que aparecem na tela em um tempo limitado. Voce pode');
   writeln('  alterar a velocidade, o n§ de bolas e a fase onde quer jogar. No campo');
   writeln('  do jogo existem 5 minas escondidas. Se encontrar uma mina, bater na');
   writeln('  parede ou ser atingido por uma bola, voce morre e perde 5 pontos. ');
   writeln('    A cada 5 unidades de tempo as minas mudam de posicao.');
   writeln('  Cada vez que pegar um objeto ganhara pontos de acordo com a seguinte');
   writeln('  formula : pontos = (n§ da velocidade) + (n§ de bolas).');
   writeln('    Por isso quanto maior for a velocidade e o n§ de bolas , mais pontos');
   writeln('  voce podera ganhar. Se estiver no modo de 2 jogadores, o jogador da');
   writeln('  direita pega o objeto ',chr(4),' e o da esquerda pega o ',chr(6),' .');
   writeln('  Controles do jogo:  P - pausa/despausa    ESC - encerra uma partida');
   writeln('                      1§ jogador: usa as setas p/ se movimentar.');
   writeln('                      2§ jogador:      W');
   writeln('                                     A S D');
   writeln('  OBS: Voce nao precisa segurar a tecla para mover o personagem. Basta');
   writeln('  da um toque na direcao desejada que ele ira.');
   writeln('  Ass: Marcos Romero G. de Almeida. E-mail: maromero@zaz.com.br');
   writeln('                    PRESSIONE ENTER P/ CONTINUAR');
   repeat
    enfeite;
    tecla_res:=ord(readkey);
    if tecla_res=0 then tecla_res:=ord(readkey)+255;
   until tecla_res=ENT;
 end;

procedure procrecorde;
var ind,rec,x,tecla_res: integer;
    s:string;
    strfase:string[3];
begin
  apagatela;
  textcolor(14);
  for ind:=1 to 5 do
      begin
           gotoxy(35,ind);
           write('RECORDES');
           escondecursor;
           textcolor(14);
           delay(100);
           if ind <> 5 then
                  apagalinha(ind);
      end;
  for ind:=1 to 3 do
      begin
           gotoxy(36,ind);
           write('MINA 2');
           escondecursor;
           textcolor(14);
           delay(100);
           if ind <> 3 then
                  apagalinha(ind);
      end;
  for rec:= 1 to QF do
      begin
           str(recordes[rec].score:3,s);
           str(rec:2,strfase);
           s:= 'FASE '+ strfase+' : '+ s + ' - '+ recordes[rec].nome;
           for ind:=80 downto 25 do
               begin
                    x:=81-ind;
                    if x>26 then x:=26;
                    gotoxy(ind,(rec*2)+6);
                    write(copy(s,1,x));
                    escondecursor;
                    textcolor(14);
                    delay(20);
                    if ind <> 25 then
                       apagalinha((rec*2)+6);
               end;
      end;
  gotoxy(25,20);
  write('Pressione ENTER para continuar.');
  repeat
   enfeite;
   tecla_res:=ord(readkey);
   if tecla_res=0 then tecla_res:=ord(readkey)+255;
  until tecla_res=ENT;
end;

procedure verificarecordes;
var texto1:PathStr;
    ind:integer;
begin
     texto1:=FSearch('recordes.mi2','.');
     if texto1 = '' then
        for ind:=1 to QF do
          begin
            recordes[ind].nome:='Computador';
            recordes[ind].score:=100;
          end
     else
        begin
          reset(frec);
          for ind:=1 to QF do
              read(frec,recordes[ind]);
        end;
end;

procedure gravarecordes;
var ind:integer;
begin
  rewrite(frec);
  for ind:=1 to QF do
      write(frec,recordes[ind]);
  close(frec);
end;

procedure menu;
 var escolha,sair:integer;
     opcoes: array[1..5] of string[20];

 begin
      sair:=0;
      opcoes[1]:='   1 JOGADOR    ';
      opcoes[2]:='   2 JOGADORES  ';
      opcoes[3]:='   RECORDES     ';
      opcoes[4]:='   INSTRUCOES   ';
      opcoes[5]:='   FINALIZAR    ';
     repeat
      apagatela;
      textcolor(14);
      textbackground(0);
      gotoxy(20,3);
      write('Ü   Ü   Ü   Ü   Ü   ÜÜÜÜÜ     ÜÜÜÜÜ'); gotoxy(20,4);
      write('ÛÛ ÛÛ   Û   ÛÛ  Û   Û   Û         Û'); gotoxy(20,5);
      write('Û Û Û   Û   Û Û Û   ÛßßßÛ     Ûßßßß'); gotoxy(20,6);
      write('Û   Û   Û   Û  ßÛ   Û   Û     ÛÜÜÜÜ');

      gotoxy(50,8);
      textcolor(15);
      write('Por Marcos Romero.');
      gotoxy(5,10);
      write('Escolha uma opcao e pressione ENTER:');
      textcolor(10); {verde}
      for escolha:= 1 to 5 do
       begin
            gotoxy(28,10 + (2 * escolha));
            write(opcoes[escolha]);
       end;
       escolha:=1;
      repeat
            textbackground(4);
            textcolor(15);
            gotoxy(28,10 + (2 * escolha));
            write(opcoes[escolha]);
            enfeite;
            tecla:=ord(readkey);
            if tecla=0 then tecla:=ord(readkey)+255;
            textbackground(0);
            textcolor(10);
            gotoxy(28,10 + (2 * escolha));
            write(opcoes[escolha]);
            case tecla of
                 CI1: begin
                           escolha:=escolha-1;
                           if escolha=0 then escolha:=5;
                      end;
                 BA1: begin
                           escolha:=escolha+1;
                           if escolha=6 then escolha:=1;
                      end;
                 ENT: case escolha of
                           1: begin
                               qjog:=1;
                               sair:=1; {encerra procedimento}
                              end;
                           2: begin
                               qjog:=2;
                               sair:=1;
                              end;
                           3: procrecorde;
                           4: instrucoes ;
                           5: begin
                               gravarecordes;
                               textcolor(15);
                               textbackground(0);
                               clrscr;
                               halt;
                              end;
                      end;
            end;
      until tecla=ENT;
     until sair=1;
 end;

procedure pegadados;
var resp1:char;
    code,ind:integer;
    resplong:string;

begin
    apagatela;
    for ind:= 1 to qjog do
      begin
        gotoxy(5,3+(2*ind));
        write('Digite o NOME do jogador ');
        if qjog=2 then
         begin
           if ind = 1 then write('da DIREITA ');
           if ind = 2 then write('da ESQUERDA ');
         end;
        write('(max. 10 letras) : ');
        readln(resplong);
        extrainfo[ind].nome:=copy(resplong,1,10);
      end;
    repeat
      gotoxy(5,9);
      write('Digite o N§ da FASE (1 a 5) : ');
      readln(fase);
    until (fase>=1) and (fase<=5);
    repeat
      gotoxy(5,11);
      write('Digite o N§ da VELOCIDADE (1 a 5) : ');
      readln(vel);
    until (vel>=1) and (vel<=5);
    repeat
      gotoxy(5,13);
      write('Digite o N§ de BOLAS (0 a 8) : ');
      readln(qbola);
    until (qbola>=0) and (qbola<=8);
    espera:=35-(5*vel);
    tempo:=49+(10*vel);
    pontoobj:=vel+qbola;
end;

procedure tela;
var i:integer;
    s,strfase:string;
begin
  apagatela;
  for i:= 1 to qjog do     {inicia dados do jogador}
    begin
      jog[i].cara:=2;
      jog[i].direcao:=0;
      extrainfo[i].score:=0;
      if i = 1 then
        begin
          jog[i].col:=28;
          jog[i].lin:=11;
          jog[i].cor:=10;
          obj[i].cara:=4;
          obj[i].cor:=10;
        end
      else
        begin
          jog[i].col:=23;
          jog[i].lin:=7;
          jog[i].cor:=14;
          obj[i].cara:=6;
          obj[i].cor:=14;
        end;
    end;
  if qbola > 0 then
    for i:= 1 to qbola do
     begin
      {bola[i].cara:=ord('0');}
      case i of
        1: begin
             bola[i].col:=3+random(3);
             bola[i].lin:=2+random(3);
             bola[i].direcao:=2;
           end;
        2: begin
             bola[i].col:=48-random(3);
             bola[i].lin:=2+random(3);
             bola[i].direcao:=3;
           end;
        3: begin
             bola[i].col:=48-random(3);
             bola[i].lin:=16-random(3);
             bola[i].direcao:=4;
           end;
        4: begin
             bola[i].col:=3+random(3);
             bola[i].lin:=16-random(3);
             bola[i].direcao:=1;
           end;
        5: begin
             bola[i].col:=25+random(2);
             bola[i].lin:=2;
             bola[i].direcao:=2;
           end;
        6: begin
             bola[i].col:=48;
             bola[i].lin:=9;
             bola[i].direcao:=3;
           end;
        7: begin
             bola[i].col:=25+random(2);
             bola[i].lin:=16;
             bola[i].direcao:=4;
           end;
        8: begin
             bola[i].col:=3;
             bola[i].lin:=9;
             bola[i].direcao:=1;
           end;
      end;
     end;

  for i:= 1 to altura do     {inicia mapa}
    for j:= 1 to largura do
        mapa[i,j]:=0;

  for i:= 1 to largura do
    begin
      mapa[1,i]:=1;
      mapa[altura,i]:=1;
    end;                      {bordas do mapa}
  for i:= 1 to altura do
    begin
      mapa[i,1]:=1;
      mapa[i,2]:=1;
      mapa[i,largura]:=1;
      mapa[i,largura-1]:=1;
    end;

  case fase of
       2: for i:= 12 to 39 do
              mapa[9,i]:=1;
       3: for i:= 5 to 13 do
            begin
              mapa[i,15]:=1;
              mapa[i,36]:=1;
            end;
       4: for i:= 12 to 39 do
            begin
              mapa[5,i]:=1;
              mapa[13,i]:=1;
              if (i=25) or (i=26) then
                begin
                  mapa[8,i]:=1;
                  mapa[9,i]:=1;
                  mapa[10,i]:=1;
                end;
            end;
       5: begin
            i:=12;
            repeat
              if(odd(i)) then
                for j:=4 to 12 do
                  mapa[j,i]:=1
              else
                for j:=6 to 14 do
                  mapa[j,i]:=1;
              i:=i+9;
            until i>39;
          end;
  end;
  textcolor(12);
  for i:= 1 to altura do
    for j:= 1 to largura do
      if mapa[i,j]=1 then
        begin
          gotoxy(j+difcol,i+diflin);
          write('Û');
        end;
  escondecursor;
  for i:= 1 to QM do
      inicia(mina[i].lin,mina[i].col);
  repeat              {inicia objeto, nao pode esta no mesmo lugar}
   for i:= 1 to qjog do
      inicia(obj[i].lin,obj[i].col);
  until (qjog = 1) or (obj[1].lin<>obj[2].lin) or (obj[1].col<>obj[2].col);
  mostra;
  str(recordes[fase].score:3,s);
  str(fase:2,strfase);
  s:= 'RECORDE DA FASE '+ strfase+' : '+ s + ' - '+ recordes[fase].nome;
  gotoxy(25,1);
  write(s);
  msg('Pressione ENTER.');
  escondecursor;
  readkey;
  apagalinha(5);
end;

procedure controle;
begin
  case tecla of
    CI1:jog[1].direcao:=1;
    DI1:jog[1].direcao:=2;
    BA1:jog[1].direcao:=3;
    ES1:jog[1].direcao:=4;
    CI2:jog[2].direcao:=1;
    DI2:jog[2].direcao:=2;
    BA2:jog[2].direcao:=3;
    ES2:jog[2].direcao:=4;
    ESC:sair:=1;
     PA:begin
          apagalinha(5);
          textcolor(15+blink);
          gotoxy(36,5);
          write('PAUSA');
          escondecursor;
          repeat
            tecla:=ord(upcase(readkey));
            if tecla=0 then tecla:=ord(readkey)+255;
          until tecla=PA;
          textcolor(15);
          apagalinha(5);
        end;
  end;
end;

procedure movecara;
var ind:integer;
begin
  for ind:= 1 to qjog do
    begin
      apaga(jog[ind].lin,jog[ind].col);
      case jog[ind].direcao of
        1:
           if mapa[jog[ind].lin-1,jog[ind].col]=1 then
                       morte(ind)
           else
                 jog[ind].lin:=jog[ind].lin-1;
        2:
           if mapa[jog[ind].lin,jog[ind].col+1]=1 then
                       morte(ind)
           else
                 jog[ind].col:=jog[ind].col+1;
        3:
           if mapa[jog[ind].lin+1,jog[ind].col]=1 then
                       morte(ind)
           else
                 jog[ind].lin:=jog[ind].lin+1;
        4:
           if mapa[jog[ind].lin,jog[ind].col-1]=1 then
                       morte(ind)
           else
                 jog[ind].col:=jog[ind].col-1;
      end;
    end;
end;

procedure movebola;
var ok,ind:integer;
begin
  for ind:= 1 to qbola do
   begin
     apaga(bola[ind].lin,bola[ind].col);
     ok:=0;
     repeat
        case bola[ind].direcao of
           1:begin
              if mapa[bola[ind].lin-1,bola[ind].col+1]=1 then
               begin
                 if((mapa[bola[ind].lin-1,bola[ind].col]=1) and
                    (mapa[bola[ind].lin,bola[ind].col+1]=1)) or
                    ((mapa[bola[ind].lin-1,bola[ind].col]=0) and
                    (mapa[bola[ind].lin,bola[ind].col+1]=0)) then
                      bola[ind].direcao:=3
                 else
                  if(mapa[bola[ind].lin-1,bola[ind].col]=1) and
                    (mapa[bola[ind].lin,bola[ind].col+1]=0) then
                      bola[ind].direcao:=2
                  else
                   if(mapa[bola[ind].lin-1,bola[ind].col]=0) and
                     (mapa[bola[ind].lin,bola[ind].col+1]=1) then
                       bola[ind].direcao:=4
               end
              else
                begin
                 bola[ind].lin:=bola[ind].lin-1;
                 bola[ind].col:=bola[ind].col+1;
                 ok:=1;
                end;
             end;

           2:begin
              if mapa[bola[ind].lin+1,bola[ind].col+1]=1 then
               begin
                if((mapa[bola[ind].lin+1,bola[ind].col]=1) and
                    (mapa[bola[ind].lin,bola[ind].col+1]=1)) or
                  ((mapa[bola[ind].lin+1,bola[ind].col]=0) and
                    (mapa[bola[ind].lin,bola[ind].col+1]=0)) then
                    bola[ind].direcao:=4
                else
                 if (mapa[bola[ind].lin+1,bola[ind].col]=1) and
                    (mapa[bola[ind].lin,bola[ind].col+1]=0) then
                    bola[ind].direcao:=1
                 else
                  if(mapa[bola[ind].lin+1,bola[ind].col]=0) and
                    (mapa[bola[ind].lin,bola[ind].col+1]=1) then
                    bola[ind].direcao:=3
               end
              else
                begin
                 bola[ind].lin:=bola[ind].lin+1;
                 bola[ind].col:=bola[ind].col+1;
                 ok:=1;
                end;
             end;

           3:begin
               if mapa[bola[ind].lin+1,bola[ind].col-1]=1 then
                begin
                 if((mapa[bola[ind].lin+1,bola[ind].col]=1) and
                   (mapa[bola[ind].lin,bola[ind].col-1]=1)) or
                   ((mapa[bola[ind].lin+1,bola[ind].col]=0) and
                   (mapa[bola[ind].lin,bola[ind].col-1]=0)) then
                   bola[ind].direcao:=1
                 else
                  if(mapa[bola[ind].lin+1,bola[ind].col]=1) and
                    (mapa[bola[ind].lin,bola[ind].col-1]=0) then
                    bola[ind].direcao:=4
                  else
                   if(mapa[bola[ind].lin+1,bola[ind].col]=0) and
                     (mapa[bola[ind].lin,bola[ind].col-1]=1) then
                     bola[ind].direcao:=2
                end
               else
                begin
                 bola[ind].lin:=bola[ind].lin+1;
                 bola[ind].col:=bola[ind].col-1;
                 ok:=1;
                end;
             end;
           4:begin
              if mapa[bola[ind].lin-1,bola[ind].col-1]=1 then
                begin
                 if((mapa[bola[ind].lin-1,bola[ind].col]=1) and
                   (mapa[bola[ind].lin,bola[ind].col-1]=1)) or
                   ((mapa[bola[ind].lin-1,bola[ind].col]=0) and
                   (mapa[bola[ind].lin,bola[ind].col-1]=0)) then
                   bola[ind].direcao:=2
                 else
                  if(mapa[bola[ind].lin-1,bola[ind].col]=1) and
                    (mapa[bola[ind].lin,bola[ind].col-1]=0) then
                    bola[ind].direcao:=3
                  else
                   if(mapa[bola[ind].lin-1,bola[ind].col]=0) and
                     (mapa[bola[ind].lin,bola[ind].col-1]=1) then
                     bola[ind].direcao:=1
                end
              else
               begin
                 bola[ind].lin:=bola[ind].lin-1;
                 bola[ind].col:=bola[ind].col-1;
                 ok:=1;
               end;
             end;
        end;
     until ok=1;
   end;
end;

procedure testaobj;
var ind:integer;
begin
  for ind:=1 to qjog do
   begin
     if (jog[ind].col=obj[ind].col) and (jog[ind].lin=obj[ind].lin) then
        begin
          extrainfo[ind].score:=extrainfo[ind].score+pontoobj;
          if qjog=2 then
            repeat
             inicia(obj[ind].lin,obj[ind].col);
            until (obj[1].lin<>obj[2].lin) or (obj[1].col<>obj[2].col)
          else
             inicia(obj[ind].lin,obj[ind].col);
        end;
   end;
end;

procedure testamina;
var ind,mi:integer;
begin
  for ind:=1 to qjog do
    for mi:= 1 to QM do
       if (jog[ind].col=mina[mi].col) and (jog[ind].lin=mina[mi].lin) then
         begin
              morte(ind);
              inicia(mina[mi].lin,mina[mi].col);
         end;
end;

procedure testabola;
var ind,bo:integer;
begin
  for ind:=1 to qjog do
    for bo:= 1 to qbola do
       if (jog[ind].col=bola[bo].col) and (jog[ind].lin=bola[bo].lin) then
              morte(ind);
end;

procedure informa;
var ind,col:integer;
begin
 for ind:=1 to qjog do   {nome e ponto do jog}
  begin
    apagalinha(5);
    textcolor(jog[ind].cor);
    if ind=1 then
       col:=67
    else
       col:=3;
    gotoxy(col,10);
    write(extrainfo[ind].nome);
    gotoxy(col+2,12);
    write(extrainfo[ind].score:3);
  end;
  textcolor(15);
  if qjog=2 then
    if extrainfo[1].score=extrainfo[2].score then
       msg('     Empate')
    else
     begin
       if extrainfo[1].score>extrainfo[2].score then
          ind:=1
       else
          ind:=2;
       msg(extrainfo[ind].nome+' esta vencendo.');
     end;
  gotoxy(35,3);
  textcolor(15);
  if tempo<=10 then textcolor(15+blink);
  write('TEMPO: ',tempo:2);

end;

procedure fimdejogo;
var ind,col,tecla_res:integer;
    s,strfase:string;
begin
  apagatela;
  textcolor(15);
  for ind:=1 to 5 do
      begin
           gotoxy(36,ind);
           write('PLACAR');
           escondecursor;
           textcolor(15);
           delay(100);
           if ind <> 5 then
                  apagalinha(ind);
      end;
  for ind:=1 to 3 do
      begin
           gotoxy(36,ind);
           write('MINA 2');
           escondecursor;
           textcolor(15);
           delay(100);
           if ind <> 3 then
                  apagalinha(ind);
      end;

  for ind:=1 to qjog do   {nome e ponto do jog}
   begin
    textcolor(jog[ind].cor);
    if ind=1 then
       col:=47
    else
       col:=23;
    gotoxy(col,8);
    write(extrainfo[ind].nome);
    gotoxy(col+2,10);
    write(extrainfo[ind].score:3);
   end;
   textcolor(15);
   ind:=1;
   if qjog=2 then
    if extrainfo[1].score=extrainfo[2].score then
     begin
       gotoxy(36,12);
       write('EMPATE');
     end
    else
     begin
       if extrainfo[1].score>extrainfo[2].score then
          ind:=1
       else
          ind:=2;
       gotoxy(30,12);
       write('VENCEDOR : '+ extrainfo[ind].nome);
     end;
   if extrainfo[ind].score > recordes[fase].score then
    begin
     textcolor(15+blink);
     gotoxy(32,14);
     write('NOVO RECORDE!');
     textcolor(15);
     recordes[fase].score:=extrainfo[ind].score;
     recordes[fase].nome:=extrainfo[ind].nome;
     str(recordes[fase].score:3,s);
     str(fase:2,strfase);
     s:= 'FASE '+ strfase+' : '+ s + ' - '+ recordes[fase].nome;
     gotoxy(28,16);
     write(s);
    end;
  gotoxy(25,20);
  write('Pressione ENTER para continuar.');
  repeat
   enfeite;
   tecla_res:=ord(upcase(readkey));
   if tecla_res=0 then tecla_res:=ord(readkey)+255;
  until tecla_res=ENT;
end;

procedure jogo;
begin
  while not(keypressed) do
    begin
      if((tempo mod 5) = 1) then
        for i:= 1 to QM do
          inicia(mina[i].lin,mina[i].col);
      if((cont mod 5) = 1) then
        begin
          movecara;
          if qbola > 0 then movebola;
          mostra;
          testaobj;
          testamina;
          if qbola > 0 then testabola;
          informa;
          escondecursor;
        end;
      if((cont mod 50) = 1) then
       begin
        tempo:=tempo-1;
        if tempo = 0 then
          begin
            fimdejogo;
            sair:=1;
            exit; {sai do proc jogo}
          end;
       end;
      delay(espera);
      cont:=cont+1;
      if cont = 30000 then cont:=0;
    end;
    tecla:=ord(upcase(readkey));
    if tecla=0 then tecla:=ord(readkey)+255;
end;

                         {programa principal}
begin
  clrscr;
  randomize;
  assign(frec,'recordes.mi2');
  verificarecordes;
  repeat
   sair:=0;
   cont:=0;
   menu;
   pegadados;
   tela;
   while sair = 0 do
    begin
      jogo;
      controle;
    end;
  until 1=0;
end.

void(vector org, vector bit1, float bit4, float flargs) make_way;
// Ways by Electro

void() map_mattrye1_nex =
{
	make_way('655.3 370.1 -34.0', '2 43 0', 0, 0);
	make_way('214.7 338.9 -34.0', '1 3 0', 0, 0);
	make_way('-70.7 197.7 -34.0', '2 4 5', 0, 0);
	make_way('-263.8  27.5 -34.0', '3 5 6', 10, 0);
	make_way('-263.8 199.7 -34.0', '4 6 3', 0, 0);
	make_way('-394.6 201.2 -34.0', '5 7 4', 0, 0);
	make_way('-617.8 260.5 -34.0', '6 8 0', 0, 0);
	make_way('-644.1 428.5 -34.0', '7 9 0', 0, 0);
	make_way('-642.2 727.9 -34.0', '8 0 0', 0, 0);
	make_way('-259.3 -187.2 -34.0', '4 11 12', 0, 0);
	make_way('-26.8 -384.2 -34.0', '10 12 32', 0, 0);
	make_way('-254.3 -368.7 -34.0', '10 11 13', 0, 0);
	make_way('-453.0 -380.6 -34.0', '12 14 0', 0, 0);
	make_way('-634.6 -436.6 -34.0', '13 15 0', 0, 0);
	make_way('-724.5 -730.3 -34.0', '14 16 0', 0, 0);
	make_way('-1118.6 -771.6 -34.0', '15 17 0', 0, 0);
	make_way('-1509.0 -737.1  62.0', '16 18 0', 0, 0);
	make_way('-1519.2 -374.8 182.0', '17 19 41', 0, 0);
	make_way('-1035.7 -196.8 182.0', '18 20 39', 41, 0);
	make_way('-749.3 -135.9 182.0', '19 21 0', 0, 0);
	make_way('-576.4 -26.8 182.0', '20 22 0', 0, 0);
	make_way('-404.1 -18.0 182.0', '21 23 12', 0, 0);
	make_way('-123.2 -18.2 182.0', '22 24 10', 12, 0);
	make_way('102.6 -27.2 182.0', '23 25 0', 0, 0);
	make_way('106.8 -383.1 182.0', '24 26 36', 0, 0);
	make_way('-232.4 -342.7 278.0', '25 27 13', 0, 0);
	make_way('-245.5 -20.1 374.0', '26 28 29', 21, 0);
	make_way('107.1   6.3 374.0', '27 25 0', 0, 0);
	make_way('-277.8 554.4 374.0', '27 30 0', 0, 0);
	make_way('-520.5 574.9 374.0', '29 31 9', 8, 0);
	make_way('-768.3 574.9 374.0', '30 8 9', 0, 0);
	make_way('465.9 -423.7 -34.0', '11 33 0', 0, 0);
	make_way('543.3 -660.4 -34.0', '32 34 0', 0, 0);
	make_way('537.0 -955.6 -34.0', '33 35 0', 0, 0);
	make_way('165.7 -926.3  86.0', '34 36 0', 0, 0);
	make_way('138.8 -740.6 155.8', '35 25 33', 0, 0);
	make_way('581.8 195.7 -21.1', '38 0 0', 0, 262144);
	make_way('847.0 120.2 191.0', '28 0 0', 0, 262144);
	make_way('-1101.5 176.0 182.0', '19 40 0', 0, 0);
	make_way('-1584.0 173.6 182.0', '39 0 0', 0, 0);
	make_way('-1295.4 -37.8 148.2', '18 42 19', 0, 0);
	make_way('-1362.7 -55.6 -221.2', '41 0 0', 0, 0);
	make_way('769.2 196.2 -34.0', '1 44 0', 0, 0);
	make_way('633.1 193.1 -34.0', '43 37 0', 0, 256);
};
/*
// Ways by Electro

void() map_mattrye2 =
{
	make_way('-652.5 -1043.9 511.0', '4 0 0', 0, 0);
	make_way('-992.5 -617.0 415.0', '3 7 0', 0, 0);
	make_way('-953.0 -50.2 351.0', '6 8 0', 0, 0);
	make_way('-647.0  77.1 351.0', '7 9 0', 0, 0);
	make_way('-698.8 764.0 239.0', '8 10 0', 0, 0);
	make_way('-1054.6 766.4 239.0', '9 11 0', 0, 0);
	make_way('-1357.9 786.5 239.0', '10 12 0', 0, 0);
	make_way('-1373.6 1502.7 127.0', '11 13 0', 0, 0);
	make_way('-1110.3 1625.0 127.0', '12 14 0', 0, 0);
	make_way('-985.9 2144.7 127.0', '13 15 0', 0, 0);
	make_way('-495.4 2230.9 127.0', '14 16 17', 0, 0);
	make_way('-47.4 2158.4 127.0', '15 40 0', 0, 0);
	make_way('-501.6 2626.1 127.0', '15 18 0', 0, 0);
	make_way('346.4 2679.1 223.0', '17 19 20', 0, 0);
	make_way('433.6 2248.8 223.0', '18 20 0', 0, 0);
	make_way('550.4 2675.8 223.0', '19 18 21', 0, 0);
	make_way('876.8 2671.6 271.0', '20 22 0', 0, 0);
	make_way('837.9 2263.6 319.0', '21 19 23', 0, 0);
	make_way('925.9 1798.9 319.0', '22 24 0', 0, 0);
	make_way('1644.3 1772.2 351.0', '23 25 0', 0, 0);
	make_way('1628.4 1068.5 351.0', '24 26 0', 0, 0);
	make_way('1409.9 965.9 351.0', '25 27 0', 0, 0);
	make_way('1073.8 789.9 351.0', '26 28 44', 45, 0);
	make_way('1408.4 645.5 416.0', '27 29 26', 0, 0);
	make_way('1653.5 624.0 479.0', '28 30 0', 0, 0);
	make_way('1662.9 317.8 479.0', '29 31 45', 0, 0);
	make_way('1637.0  28.1 479.0', '30 32 0', 0, 0);
	make_way('1060.8 -48.7 479.0', '31 33 0', 0, 0);
	make_way('996.9 -484.3 479.0', '32 34 0', 0, 0);
	make_way('550.8 -491.1 479.0', '33 35 37', 39, 0);
	make_way('542.9 -914.0 479.0', '34 36 37', 39, 0);
	make_way('712.4 -1089.3 511.0', '35 0 0', 0, 0);
	make_way('-13.4 -289.6 479.0', '34 39 35', 3, 0);
	make_way('-97.3 -677.8 479.0', '2 4 3', 0, 0);
	make_way('144.7 -679.1 479.0', '35 37 34', 0, 0);
	make_way('2.3 1824.9 127.0', '16 41 0', 0, 0);
	make_way('6.0 1232.9 127.0', '40 42 0', 0, 0);
	make_way('10.5 768.3 127.0', '41 43 0', 0, 0);
	make_way('5.0 375.1 127.0', '42 44 0', 0, 0);
	make_way('875.6 378.7 351.0', '43 45 27', 0, 0);
	make_way('1090.9 453.8 351.0', '44 27 0', 0, 0);
	make_way('-560.0 1269.1 351.0', '0 0 0', 0, 0);
	make_way('-434.0 1282.5 127.0', '41 40 42', 0, 0);
	make_way('602.4 1275.2 351.0', '0 0 0', 0, 0);
	make_way('430.0 1282.1 127.0', '41 42 40', 0, 0);
};

// Ways by Electro

void() map_mattrye1_nex =
{
	make_way('655.3 370.1 -34.0', '2 43 0', 0, 0);
	make_way('214.7 338.9 -34.0', '1 3 0', 0, 0);
	make_way('-70.7 197.7 -34.0', '2 4 5', 0, 0);
	make_way('-263.8  27.5 -34.0', '3 5 6', 10, 0);
	make_way('-263.8 199.7 -34.0', '4 6 3', 0, 0);
	make_way('-394.6 201.2 -34.0', '5 7 4', 0, 0);
	make_way('-617.8 260.5 -34.0', '6 8 0', 0, 0);
	make_way('-644.1 428.5 -34.0', '7 9 0', 0, 0);
	make_way('-642.2 727.9 -34.0', '8 0 0', 0, 0);
	make_way('-259.3 -187.2 -34.0', '4 11 12', 0, 0);
	make_way('-26.8 -384.2 -34.0', '10 12 32', 0, 0);
	make_way('-254.3 -368.7 -34.0', '10 11 13', 0, 0);
	make_way('-453.0 -380.6 -34.0', '12 14 0', 0, 0);
	make_way('-634.6 -436.6 -34.0', '13 15 0', 0, 0);
	make_way('-724.5 -730.3 -34.0', '14 16 0', 0, 0);
	make_way('-1118.6 -771.6 -34.0', '15 17 0', 0, 0);
	make_way('-1509.0 -737.1  62.0', '16 18 0', 0, 0);
	make_way('-1519.2 -374.8 182.0', '17 19 41', 0, 0);
	make_way('-1035.7 -196.8 182.0', '18 20 39', 41, 0);
	make_way('-749.3 -135.9 182.0', '19 21 0', 0, 0);
	make_way('-576.4 -26.8 182.0', '20 22 0', 0, 0);
	make_way('-404.1 -18.0 182.0', '21 23 12', 0, 0);
	make_way('-123.2 -18.2 182.0', '22 24 10', 12, 0);
	make_way('102.6 -27.2 182.0', '23 25 0', 0, 0);
	make_way('106.8 -383.1 182.0', '24 26 36', 0, 0);
	make_way('-232.4 -342.7 278.0', '25 27 13', 0, 0);
	make_way('-245.5 -20.1 374.0', '26 28 29', 21, 0);
	make_way('107.1   6.3 374.0', '27 25 0', 0, 0);
	make_way('-277.8 554.4 374.0', '27 30 0', 0, 0);
	make_way('-520.5 574.9 374.0', '29 31 9', 8, 0);
	make_way('-768.3 574.9 374.0', '30 8 9', 0, 0);
	make_way('465.9 -423.7 -34.0', '11 33 0', 0, 0);
	make_way('543.3 -660.4 -34.0', '32 34 0', 0, 0);
	make_way('537.0 -955.6 -34.0', '33 35 0', 0, 0);
	make_way('165.7 -926.3  86.0', '34 36 0', 0, 0);
	make_way('138.8 -740.6 155.8', '35 25 33', 0, 0);
	make_way('581.8 195.7 -21.1', '38 0 0', 0, 262144);
	make_way('847.0 120.2 191.0', '28 0 0', 0, 262144);
	make_way('-1101.5 176.0 182.0', '19 40 0', 0, 0);
	make_way('-1584.0 173.6 182.0', '39 0 0', 0, 0);
	make_way('-1295.4 -37.8 148.2', '18 42 19', 0, 0);
	make_way('-1362.7 -55.6 -221.2', '41 0 0', 0, 0);
	make_way('769.2 196.2 -34.0', '1 44 0', 0, 0);
	make_way('633.1 193.1 -34.0', '43 37 0', 0, 256);
};
*/

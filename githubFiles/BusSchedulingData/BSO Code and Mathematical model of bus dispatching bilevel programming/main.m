% ���������� ��������ʱ��T �������interval ��ʱ����ʻ�ٶ�v  6�㵽22��
% ������·�� �����ض���·�����г�վ���������(km)
% �˿���Ϣ�� �����˿�ID ���������վ��ʱ��t ����վ��Ŀ��վ �Լ����յĵȴ�ʱ��
% ������Ϣ�� ��������ID ����ʱ�� ÿվ�㵽վʱ�� �˿�ID �˳����ʶ� �ؿ������
% ͨ���Է�������복����ʻ�ٶȵĿ��ƣ���֤����ʵ��ʹ���������������ʣ�����ʼ����ת ���򷢳������ͣת���� �˳����ʶȺ��ؿ������֮���ƽ��
% ����������·��֮���ϸ΢���� ��֮����
clear;clc;
%% init_parameters
global Parameters;
Parameters = struct(); % Parameters �ǰ��������г������Ľṹ��
Parameters.stations_num = 40;
Parameters.passenger_up = 20000;
Parameters.passenger_down = 20000;
Parameters.passenger_sum = Parameters.passenger_up + Parameters.passenger_down;
Parameters.seats = 40;
Parameters.passengers_max = 100;
Parameters.updown_time = 10; % ��λ ��
Parameters.speed_max = 40; % ��λ km/h
Parameters.intervals = zeros(2,16); % ��λ ����
Parameters.intervals(:) = 10;
Parameters.speed = zeros(2,16); % ��λ km/h
Parameters.speed(:) = 30;
Parameters.stations = randi([500,1000],1,Parameters.stations_num-1); % Stations(i) ��ʾiվ����i+1վ��֮��ľ��� ��λΪ��
Parameters.buses = struct(); % Buses �ǰ��������г����Ľṹ��
Parameters.passengers_up = zeros(Parameters.passenger_up,4); % Passengers �ǰ��������г˿͵Ľṹ��
Parameters.passengers_down = zeros(Parameters.passenger_down,4);
rand_time_up = sort(randi(3600*16 - 1,1,Parameters.passenger_up));
rand_time_down = sort(randi(3600*16 - 1,1,Parameters.passenger_down));
for i=1:Parameters.passenger_up
    Parameters.passengers_up(i,1) = rand_time_up(i);
    Parameters.passengers_up(i,2) = randi(Parameters.stations_num-1);
    Parameters.passengers_up(i,3) = randi([Parameters.passengers_up(i,2)+1,Parameters.stations_num]);
    Parameters.passengers_up(i,4) = -1;
end
for i=1:Parameters.passenger_down
    Parameters.passengers_down(i,1) = rand_time_down(i);
    Parameters.passengers_down(i,2) = randi(Parameters.stations_num-1);
    Parameters.passengers_down(i,3) = randi([Parameters.passengers_down(i,2)+1,Parameters.stations_num]);
    Parameters.passengers_down(i,4) = -1;
end
%% loop the simulation
% ���㳵�������
% ��ʼ��������Ϣ�� ��������ID ����ʱ�� ÿվ�㵽վʱ�� �˿�ID �˳����ʶ� �ؿ������
cur_index_up = [];
cur_index_down = [];
cur_free_bus = [0,0]; % ͣת������Ŀ
total_bus = 0; % ʵ��Ͷ�����г�������
next_index = 1;
time_up = [];
time_down = [];
for i=1:16
    time_up = [time_up (1+(i-1)*3600):Parameters.intervals(1,i)*60:i*3600];
    time_down = [time_down (1+(i-1)*3600):Parameters.intervals(2,i)*60:i*3600];
end
time_total = [time_up time_down];
time_total = unique(sort(time_total));
for i=1:length(time_total)
    % ����������������Ϣ
    % ����
    if find(time_up == time_total(i))
        if cur_free_bus(1) > 0
            cur_free_bus(1) = cur_free_bus(1) - 1;
            total_bus = total_bus - 1;
        end
        updateBus(time_total(i),1,next_index)
        cur_index_up = [cur_index_up next_index];
        next_index = next_index + 1;
        total_bus = total_bus + 1;
    end
    % ����
    if find(time_down == time_total(i))
        if cur_free_bus(2) > 0
            cur_free_bus(2) = cur_free_bus(2) - 1;
            total_bus = total_bus - 1;
        end
        updateBus(time_total(i),2,next_index)
        cur_index_down = [cur_index_down next_index];
        next_index = next_index + 1;
        total_bus = total_bus + 1;
    end
    
    % �������еĳ���ID�Լ����õĳ����� �ٶ��ȷ��ĳ���Զ�ں󷢵ĳ�ǰ�� ���ᱻ������
    % ����ֻ��Ҫ��ÿ�η���ʱ�̸�����/���е�����������
    if Parameters.buses(cur_index_up(1)).details{1,Parameters.stations_num} <= time_total(i)
        cur_free_bus(2) = cur_free_bus(2) + 1;
        cur_index_up(1) = [];
    end
    if Parameters.buses(cur_index_down(1)).details{1,Parameters.stations_num} <= time_total(i)
        cur_free_bus(1) = cur_free_bus(1) + 1;
        cur_index_down(1) = [];
    end
end
% ����˿͵ĵȴ�ʱ���Լ���������
for i=1:next_index-1
    type = Parameters.buses(i).type;
    if type == 1 % ����
        for j=1:Parameters.stations_num-1
            time = Parameters.buses(i).details{1,j};
            % �³�
            if ~isempty(Parameters.buses(i).details{2,j})
                index_down = find(Parameters.passengers_up(Parameters.buses(i).details{2,j},3) == j);
                Parameters.buses(i).details{2,j}(index_down) = [];
            end
            % �ϳ�
            index = find(Parameters.passengers_up(:,2) == j & Parameters.passengers_up(:,1) <= time & Parameters.passengers_up(:,4) == -1);
            if length(index) > Parameters.passengers_max
                index = index(1:Parameters.passengers_max);
            end
            Parameters.buses(i).details{2,j} = index;
            for k=1:length(index)
                Parameters.passengers_up(index(k),4) = time - Parameters.passengers_up(index(k),1);
            end
        end
    else % ����
        for j=1:Parameters.stations_num-1
            time = Parameters.buses(i).details{1,j};
            % �³�
            if ~isempty(Parameters.buses(i).details{2,j})
                index_down = find(Parameters.passengers_down(Parameters.buses(i).details{2,j},3) == j);
                Parameters.buses(i).details{2,j}(index_down) = [];
            end
            % �ϳ�
            index = find(Parameters.passengers_down(:,2) == j & Parameters.passengers_down(:,1) <= time & Parameters.passengers_down(:,4) == -1);
            if length(index) > Parameters.passengers_max
                index = index(1:Parameters.passengers_max);
            end
            Parameters.buses(i).details{2,j} = index;
            for k=1:length(index)
                Parameters.passengers_down(index(k),4) = time - Parameters.passengers_down(index(k),1);
            end
        end
    end
end
% ����˿͵ȴ�ʱ�������
high = [2,3,12,13];
pass_up = Parameters.passengers_up(:,[1,4]);
pass_up(:,1) = floor(pass_up(:,1)/3600) + 1;
pass_down = Parameters.passengers_down(:,[1,4]);
pass_down(:,1) = floor(pass_down(:,1)/3600) + 1;
W = 0;
for i=1:Parameters.passenger_up
    res = getWaitSatis(pass_up(i,1),pass_up(i,2),high);
    W = W + res;
end
for i=1:Parameters.passenger_down
    res = getWaitSatis(pass_down(i,1),pass_down(i,2),high);
    W = W + res;
end
W = W / Parameters.passenger_sum;
% ����˿ͳ˳����ʶ�
S = 0;
for i=1:next_index - 1
    for j=1:Parameters.stations_num
        res = getTravelSatis(Parameters.seats,length(Parameters.buses(i).details{2,j}));
        S = S + res;
    end    
end
satis_passenger = (0.7 * W + 0.3 * S) / 2;
% ������˾�ؿ������
satis_bus = 0;
for i=1:next_index - 1
    for j=1:Parameters.stations_num-1
        res = getTravelSatis(Parameters.seats,length(Parameters.buses(i).details{2,j}));
        satis_bus = satis_bus + res;
    end    
end
satis_bus = satis_bus / (Parameters.stations_num-1) / (next_index-1);
cost = 100;
cost_bus = total_bus * cost;
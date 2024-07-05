% WIFI & ROUTE MAPPING PROJECT
%Calculating route of walk using IMU sensors: accelometer,gyroscope.
%Or Simchy 2024


%import data
acc_data = readtable("small_data.csv");

time = acc_data.time;

% acceleration data
ay = acc_data.ay;
az = acc_data.az;
ax = acc_data.ax ;

%gyroscope data
wz = acc_data.wz;
wx = acc_data.wx;
wy = acc_data.wy;



%angle_z_gyro will be calculated from gyro (phi)
angle_z_gyro = zeros(size(time));

%calc angle phi over time
for i = 2:length(angle_z_gyro)
    dt = time(i)- time(i-1);
    angle_z_gyro(i) = angle_z_gyro(i-1) + wz(i) * dt;
end

%the gyro data is rad/sec - match the scale- rad to deg
angle_z_gyro = (180/pi)*angle_z_gyro;


%low pass filter- acceleration

% Define the sampling frequency 100 (Hz)
Fs = 100;  

% Define the cutoff frequency (Hz)
Fc = 7;  

% Apply the low-pass filter 
filtered_acceleration = lowpass(ay, Fc, Fs);


% Plot the original and filtered data for comparison
%t = (0:length(filtered_acceleration)-1)/Fs;  
% plot(t, ay);
% title('Original Accelerometer Data');
% xlabel('Time (s)');
% ylabel('Acceleration (m/s^2)');
% 
% plot(t, filtered_acceleration);
% title('Filtered Accelerometer Data');
% xlabel('Time (s)');
% ylabel('Acceleration (m/s^2)');

filtered_acceleration_y = zeros(size(filtered_acceleration));
filtered_acceleration_x = zeros(size(filtered_acceleration));

%correcting the acceleration's direction to match the rooms coardinates
for i = 2:length(ax)
    dt = time(i)- time(i-1);
    filtered_acceleration_x(i) = -sind(angle_z_gyro(i))*abs((filtered_acceleration(i)));
    filtered_acceleration_y(i) = cosd(angle_z_gyro(i))*abs((filtered_acceleration(i)));
end

% plot(time, filtered_acceleration_x);
% title("filteres ax");
% xlabel("time [s]");
% ylabel("acceleration x [m/s^2]");

%creating is_moving boolean vector for movement on x direction
threshold = 0.08;
is_moving_x = ones(size(filtered_acceleration_x));

for i=2:length(is_moving_x)
    if abs(filtered_acceleration_x(i))<threshold && sqrt(wx(i)^2+wy(i)^2)<0.1
        is_moving_x(i)=0;
    end
     if abs(filtered_acceleration_x(i))>1.4
        is_moving_x(i)=0;
    end
end

%calc velocity
vx = zeros(size(filtered_acceleration_x));
for i=2:length(filtered_acceleration_x)
    dt = time(i)- time(i-1);
    if is_moving_x(i)
        vx(i)= vx(i-1)+ filtered_acceleration_x(i)*dt;
    end
end

%calc x location
pos_x = zeros(size(vx));
for i=2:length(vx)
    dt = time(i)- time(i-1);
    pos_x(i)= pos_x(i-1)+ vx(i)*dt;
end

% plot(time, pos_x);
% title("X position");
% xlabel("time [s]");
% ylabel("x position [m]");

% 
% plot(time, filtered_acceleration_y);
% title("filt acc_y");

is_moving_y = ones(size(filtered_acceleration_y));

for i=2:length(is_moving_y)
    if abs(filtered_acceleration_y(i))<threshold && sqrt(wx(i)^2+wy(i)^2)<0.1
        is_moving_y(i)=0;
    end 
    if abs(filtered_acceleration_y(i))>1.4
        is_moving_y(i)=0;
    end
end


vy = zeros(size(filtered_acceleration_y));
for i=2:length(filtered_acceleration_y)
    dt = time(i)- time(i-1);
    if is_moving_y(i)
        vy(i)= vy(i-1)+ filtered_acceleration_y(i)*dt;
    end
end

pos_y = zeros(size(vy));

for i=2:length(vy)
    dt = time(i)- time(i-1);
    pos_y(i)= pos_y(i-1)+ vy(i)*dt;
end

% plot(time, pos_y);
% title("Y position");
% xlabel("time [s]");
% ylabel("y position [m]");


plot(pos_x, pos_y, LineWidth=3);
xlabel("x position [m]");
ylabel("y position [m]");
grid on;


%creating wifi strength vector (dummy data)
strength = linspace(1, 100, length(filtered_acceleration));
strength = strength';

%define grid
x_grid_min = min(pos_x);
x_grid_max = max(pos_x);
y_grid_min = min(pos_y);
y_grid_max = max(pos_y);

% Create a grid of points
grid_resolution = 100; % Adjust resolution as needed
x_grid = linspace(x_grid_min, x_grid_max, grid_resolution);
y_grid = linspace(y_grid_min, y_grid_max, grid_resolution);
[X, Y] = meshgrid(x_grid, y_grid);

% Interpolate WiFi strength over the grid
Z = griddata(pos_x, pos_y, strength, X, Y, 'cubic');

% Plot the heat map
figure;
imagesc(x_grid, y_grid, Z);
set(gca, 'YDir', 'normal'); % Correct the Y-axis direction
colorbar;
title('WiFi Signal Strength Heat Map');
xlabel('X');
ylabel('Y');


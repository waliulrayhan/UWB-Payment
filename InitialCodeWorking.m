% ---------------------------
% Dhaka Metro UWB-Based Simulation
% ---------------------------
clear; clc; close all;

% ---------------------------
% Dhaka Metro Station Configuration
% ---------------------------
% Define stations array to match fare chart (with display names)
station_display_names = ["Uttara North", "Uttara Center", "Uttara South", "Pallabi", "Mirpur 11", "Mirpur 10", "Kazipara", "Shewrapara", "Agargaon"];

% Define stations with valid field names
stations = ["Uttara_North", "Uttara_Center", "Uttara_South", "Pallabi", ...
           "Mirpur_11", "Mirpur_10", "Kazipara", "Shewrapara", "Agargaon"];

% Define station positions (coordinates in kilometers)
station_positions = [
    0, 0;    % Uttara North
    1.2, 0;  % Uttara Center
    2.4, 0;  % Uttara South
    3.8, 0;  % Pallabi
    5.1, 0;  % Mirpur 11
    6.3, 0;  % Mirpur 10
    7.5, 0;  % Kazipara
    8.7, 0;  % Shewrapara
    10.0, 0  % Agargaon
];

% ---------------------------
% Dhaka Metro Fare Chart
% ---------------------------
dhaka_metro_fare = struct(...
    'Uttara_North', struct('Uttara_North', 0, 'Uttara_Center', 20, 'Uttara_South', 30, 'Pallabi', 40, ...
                          'Mirpur_11', 50, 'Mirpur_10', 60, 'Kazipara', 70, 'Shewrapara', 80, 'Agargaon', 90), ...
    'Uttara_Center', struct('Uttara_North', 20, 'Uttara_Center', 0, 'Uttara_South', 20, 'Pallabi', 30, ...
                           'Mirpur_11', 40, 'Mirpur_10', 50, 'Kazipara', 60, 'Shewrapara', 70, 'Agargaon', 80), ...
    'Uttara_South', struct('Uttara_North', 30, 'Uttara_Center', 20, 'Uttara_South', 0, 'Pallabi', 20, ...
                          'Mirpur_11', 30, 'Mirpur_10', 40, 'Kazipara', 50, 'Shewrapara', 60, 'Agargaon', 70), ...
    'Pallabi', struct('Uttara_North', 40, 'Uttara_Center', 30, 'Uttara_South', 20, 'Pallabi', 0, ...
                     'Mirpur_11', 20, 'Mirpur_10', 30, 'Kazipara', 40, 'Shewrapara', 50, 'Agargaon', 60), ...
    'Mirpur_11', struct('Uttara_North', 50, 'Uttara_Center', 40, 'Uttara_South', 30, 'Pallabi', 20, ...
                       'Mirpur_11', 0, 'Mirpur_10', 20, 'Kazipara', 30, 'Shewrapara', 40, 'Agargaon', 50), ...
    'Mirpur_10', struct('Uttara_North', 60, 'Uttara_Center', 50, 'Uttara_South', 40, 'Pallabi', 30, ...
                       'Mirpur_11', 20, 'Mirpur_10', 0, 'Kazipara', 20, 'Shewrapara', 30, 'Agargaon', 40), ...
    'Kazipara', struct('Uttara_North', 70, 'Uttara_Center', 60, 'Uttara_South', 50, 'Pallabi', 40, ...
                      'Mirpur_11', 30, 'Mirpur_10', 20, 'Kazipara', 0, 'Shewrapara', 20, 'Agargaon', 30), ...
    'Shewrapara', struct('Uttara_North', 80, 'Uttara_Center', 70, 'Uttara_South', 60, 'Pallabi', 50, ...
                        'Mirpur_11', 40, 'Mirpur_10', 30, 'Kazipara', 20, 'Shewrapara', 0, 'Agargaon', 20), ...
    'Agargaon', struct('Uttara_North', 90, 'Uttara_Center', 80, 'Uttara_South', 70, 'Pallabi', 60, ...
                      'Mirpur_11', 50, 'Mirpur_10', 40, 'Kazipara', 30, 'Shewrapara', 20, 'Agargaon', 0) ...
);

% Define Passengers - Added Balance Field
passengers = struct();
passengers(1).ID = 'P001';
passengers(1).Position = [0, 0];
passengers(1).Status = 'Waiting';
passengers(1).EntryStation = '';
passengers(1).EntryTime = [];
passengers(1).Balance = 100;  % Initialize balance (BDT 100)

passengers(2).ID = 'P002';
passengers(2).Position = [0, 0];
passengers(2).Status = 'Waiting';
passengers(2).EntryStation = '';
passengers(2).EntryTime = [];
passengers(2).Balance = 80;  % Initialize balance (BDT 80)

passengers(3).ID = 'P003';
passengers(3).Position = [0, 0];
passengers(3).Status = 'Waiting';
passengers(3).EntryStation = '';
passengers(3).EntryTime = [];
passengers(3).Balance = 40;  % Initialize balance (BDT 50)


% [Previous helper functions remain the same]

% ---------------------------
% Helper Function: Convert Station Name to Struct Field Format
% ---------------------------
function fieldName = getFieldName(stationName)
    fieldName = strrep(stationName, " ", "_"); % Replace spaces with underscores
end

% ---------------------------
% Helper Function: Convert Struct Field Format to Display Name
% ---------------------------
function displayName = getDisplayName(fieldName)
    displayName = strrep(fieldName, "_", " "); % Replace underscores with spaces
end

% ---------------------------
% Helper Function: Check if Station Name is Valid
% ---------------------------
function valid = isValidStation(stationName, stations)
    fieldName = getFieldName(stationName); % Convert to struct field format
    valid = any(strcmp(stations, fieldName)); % Check if station exists in the list
end



% ---------------------------
% Function: Passenger Entry Detection
% ---------------------------
function passengers = enterStation(passengers, passengerID, stationName, stations, station_positions)
    fieldName = getFieldName(stationName);
    if ~isValidStation(stationName, stations)
        fprintf("ERROR: Invalid station name '%s'\n", stationName);
        return;
    end
    
    % Fixed passenger ID comparison
    passengerIDs = {passengers.ID};
    passengerIndex = find(strcmp(passengerIDs, passengerID));
    
    if isempty(passengerIndex)
        fprintf("ERROR: Invalid passenger ID '%s'\n", passengerID);
        return;
    end
    
    stationIndex = find(strcmp(stations, fieldName));
    
    % Update Passenger Information
    passengers(passengerIndex).Status = 'Inside Metro';
    passengers(passengerIndex).Position = station_positions(stationIndex, :);
    passengers(passengerIndex).EntryStation = fieldName;
    passengers(passengerIndex).EntryTime = now; % Store entry time
    
    fprintf("Passenger %s entered %s at %s\n", ...
            passengerID, stationName, datestr(now, 'HH:MM:SS'));
end

% ---------------------------
% Function: Passenger Traveling (With Visualization)
% ---------------------------
function passengers = travelToStation(passengers, passengerID, destination, stations, station_positions)
    fieldName = getFieldName(destination);
    if ~isValidStation(destination, stations)
        fprintf("ERROR: Invalid destination station '%s'\n", destination);
        return;
    end
    
    % Find passenger index
    passengerIDs = {passengers.ID};
    passengerIndex = find(strcmp(passengerIDs, passengerID));
    
    if isempty(passengerIndex)
        fprintf("ERROR: Invalid passenger ID '%s'\n", passengerID);
        return;
    end
    
    % Get station indices
    startPos = passengers(passengerIndex).Position;
    endPos = station_positions(find(strcmp(stations, fieldName)), :);
    
    % Calculate distance
    distance = norm(endPos - startPos);
    
    fprintf("🚆 Passenger %s is traveling %.2f km to %s...\n", ...
            passengerID, distance, destination);
    
    % Simulate movement with visualization
    steps = round(distance * 10); % More granular steps for smooth animation
    if steps == 0
        steps = 1;
    end

    figure(1); clf; hold on; grid on;
    title('Dhaka Metro Passenger Movement');
    xlabel('Distance (km)'); ylabel('Station');
    ylim([-1, 1]); % Keep the passenger movement on one line
    xlim([0, max(station_positions(:,1)) + 1]);
    yticks([]); % Remove y-axis ticks
    plot(station_positions(:,1), zeros(size(station_positions,1),1), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); % Stations

    % Animate passenger movement
    for i = 1:steps
        passengerPos = startPos + (i/steps) * (endPos - startPos);
        plot(passengerPos(1), 0, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b'); % Passenger
        pause(0.1);
    end

    passengers(passengerIndex).Position = endPos;
    fprintf("✅ Passenger %s arrived at %s\n", passengerID, destination);
end


% ---------------------------
% Function: Passenger Exit & Fare Calculation (With Balance Check)
% ---------------------------
function passengers = exitStation(passengers, passengerID, exitStation, dhaka_metro_fare)
    exitFieldName = getFieldName(exitStation);
    
    % Find passenger index
    passengerIDs = {passengers.ID};
    passengerIndex = find(strcmp(passengerIDs, passengerID));
    
    if isempty(passengerIndex)
        fprintf("ERROR: Invalid passenger ID '%s'\n", passengerID);
        return;
    end
    
    entryFieldName = passengers(passengerIndex).EntryStation;
    if isempty(entryFieldName) || strcmp(entryFieldName, '')
        disp("ERROR: No entry station recorded for this passenger");
        return;
    end
    
    % Retrieve fare
    if isfield(dhaka_metro_fare, entryFieldName) && isfield(dhaka_metro_fare.(entryFieldName), exitFieldName)
        fare = dhaka_metro_fare.(entryFieldName).(exitFieldName);
        
        % Check passenger balance before deducting
        if passengers(passengerIndex).Balance < fare
            fprintf("❌ ERROR: Insufficient balance for Passenger %s (Balance: BDT %.2f, Fare: BDT %.2f)\n", ...
                    passengerID, passengers(passengerIndex).Balance, fare);
            return;
        end
        
        % Deduct fare from balance
        passengers(passengerIndex).Balance = passengers(passengerIndex).Balance - fare;
        
        % Calculate journey duration using metro speed
        avg_speed_kmph = 30; % Metro average speed in km/h
        distance = fare / 10; % Approximate km distance using fare (each BDT 10 ≈ 1 km)
        journeyDuration = (distance / avg_speed_kmph) * 60; % Convert hours to minutes

        % Update passenger status
        passengers(passengerIndex).Status = 'Exited';
        passengers(passengerIndex).EntryStation = '';
        passengers(passengerIndex).EntryTime = [];

        % Display final journey summary
        fprintf("\n🚆 Journey Summary for Passenger %s:\n", passengerID);
        fprintf("  ✅ From: %s\n", getDisplayName(entryFieldName));
        fprintf("  ✅ To: %s\n", exitStation);
        fprintf("  ⏳ Duration: %.1f minutes\n", journeyDuration);
        fprintf("  💰 Fare: BDT %.2f\n", fare);
        fprintf("  🏦 Remaining Balance: BDT %.2f\n\n", passengers(passengerIndex).Balance);
    else
        fprintf("ERROR: Cannot calculate fare between %s and %s\n", getDisplayName(entryFieldName), exitStation);
    end
end


% ---------------------------
% Run Parallel Passenger Simulation
% ---------------------------
disp("Dhaka Metro UWB Simulation Started...");
disp("Available Stations:");
disp(join(station_display_names, ", "));

% Define passengers dynamically
passengers(1) = enterStation(passengers(1), "P001", "Uttara North", stations, station_positions);
passengers(2) = enterStation(passengers(2), "P002", "Kazipara", stations, station_positions);
passengers(3) = enterStation(passengers(3), "P003", "Pallabi", stations, station_positions);

pause(1); % Simulate short waiting time

% Move all passengers to different destinations
passengers(1) = travelToStation(passengers(1), "P001", "Mirpur 10", stations, station_positions);
passengers(2) = travelToStation(passengers(2), "P002", "Agargaon", stations, station_positions);
passengers(3) = travelToStation(passengers(3), "P003", "Shewrapara", stations, station_positions);

pause(1); % Simulate short waiting time

% Exit all passengers and calculate fare
passengers(1) = exitStation(passengers(1), "P001", "Mirpur 10", dhaka_metro_fare);
passengers(2) = exitStation(passengers(2), "P002", "Agargaon", dhaka_metro_fare);
passengers(3) = exitStation(passengers(3), "P003", "Shewrapara", dhaka_metro_fare);

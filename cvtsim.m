function cvtsim()

data = createData();
gui = createInterface( data.SimNames, data.HelixNames, data.RampNames );

% Now update the GUI with the current data
updateInterface();
redrawSim();

% Explicitly call the demo display so that it gets included if we deploy
displayEndOfSimMessage('')

%-------------------------------------------------------------------------%

 function data = createData()
        % Create the shared data-structure for this application
        simList = {
            'CVT Sim 1'                  'sim1'
            'CVT Sim 2'                  'sim2'
            'CVT Sim 3'                  'sim3'
            'etc'                        'etcet'
            };
        selectedSim = 1;
        
        helixList = {
            '28'                         'helix28'
            '33'                         'helix33'
            '36'                         'helix36'
            '38'                         'helix38'
            '40'                         'helix40'
            'multi'                      'helixmulti'
            };
        selectedHelix = 1;
        
        rampList = {
            'mod1'                       'rampmod1'
            'mod2'                       'rampmod2'
            'mod3'                       'rampmod3'
            'mod4'                       'rampmod4'
            '18-8'                       'ramp18_8'
            };
        selectedRamp = 1;
        
        data = struct( ...
            'SimNames', {simList(:,1)'}, ...
            'SimFunctions', {simList(:,2)'}, ...
            'SelectedSim', selectedSim, ...
            'HelixNames', {helixList(:,1)'}, ...
            'HelixFunctions', {helixList(:,2)'}, ...
            'SelectedHelix', selectedHelix, ...
            'RampNames', {rampList(:,1)'}, ...
            'RampFunctions', {rampList(:,2)'}, ...
            'SelectedRamp', selectedRamp);
        
    end % createData

%-------------------------------------------------------------------------%

function gui = createInterface( simList, helixList, rampList )
        % Create the user interface for the application and return a
        % structure of handles for global use.
        gui = struct();
        % Open a window and add some menus
        gui.Window = figure( ...
            'Name', 'CVT Simulation', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'Position', [200 100 900 500], ...
            'HandleVisibility', 'off' );
        
        % + File menu
        gui.FileMenu = uimenu( gui.Window, 'Label', 'File' );
        uimenu( gui.FileMenu, 'Label', 'Exit', 'Callback', @onExit );
        
        % + Help menu
        helpMenu = uimenu( gui.Window, 'Label', 'Help' );
        uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @onHelp );
        
        % Arrange the main interface
        mainLayout = uix.HBoxFlex( 'Parent', gui.Window, 'Spacing', 3 );
        
        % + Create the panels
        controlPanel = uix.BoxPanel( ...
            'Parent', mainLayout, ...
            'Title', 'Select Simulation Characteristics: ' );
        
%         tabPanel = uix.TabPanel('Parent', mainLayout);
%         gui.ViewPanel = uix.BoxPanel( ...
%             'Parent', tabPanel, ...
%             'Title', 'Viewing: ???', ...
%             'HelpFcn', @onSimHelp );

        gui.ViewPanel = uix.BoxPanel( ...
                    'Parent', mainLayout, ...
                    'Title', 'Viewing: ???', ...
                    'HelpFcn', @onSimHelp );
        gui.ViewContainer = uicontainer( ...
            'Parent', gui.ViewPanel );        

        % + Adjust the main layout
        set( mainLayout, 'Widths', [-2,-3]  );
        
        controlLayout = uix.VBox( 'Parent', controlPanel, ...
            'Padding', 3, 'Spacing', 3 );
        
        SimSelectLayout = uix.HBox( 'Parent', controlLayout, ...
            'Padding', 3, 'Spacing', 3 );
        
        gui.ChooseSim = uicontrol( 'Style', 'text', ...
            'Parent', SimSelectLayout, ...
            'String', 'Select Simulation Type: ', ...
            'FontSize', 9, 'FontWeight', 'bold');
        
        gui.ListBox = uicontrol( 'Style', 'popupmenu', ...
            'Parent', SimSelectLayout, ...
            'String', simList(:), ...
            'Value', 1, ...
            'Callback', @onListSelection);
        
        %%% CVT Specs
        
        gui.CVTText = uicontrol( 'Style', 'text', ...
            'Parent', controlLayout, ...
            'String', 'CVT Specifications: ', ...
            'FontSize', 9, 'FontWeight', 'bold');
        
        CVTLayout = uix.Grid( 'Parent', controlLayout, ...
            'Padding', 3, 'Spacing', 3 );
        
        gui.LatDispText = uicontrol( 'Style', 'text', ...
            'Parent', CVTLayout, ...
            'String', 'Lateral Displacement of Pulley: ');
        
        gui.CoFricText = uicontrol( 'Style', 'text', ...
            'Parent', CVTLayout, ...
            'String', 'Coefficient of Friction: ');
        
        gui.TestRPMsText = uicontrol( 'Style', 'text', ...
            'Parent', CVTLayout, ...
            'String', 'Test RPMs (Arbitrary): ');
        
        gui.LatDisp = uicontrol( 'Style', 'edit', ...
            'Parent', CVTLayout, ...
            'String', '[0 0.097 .194 .292 .389 .486 .583 .680 .729]');
        
        gui.CoFric = uicontrol( 'Style', 'edit', ...
            'Parent', CVTLayout, ...
            'String', '1');
        
        gui.TestRPMs = uicontrol( 'Style', 'edit', ...
            'Parent', CVTLayout, ...
            'String', '[2500 2900 3300 3600]');
        
        set( CVTLayout, 'Heights', [-2 -1 -1], 'Widths', [-2 -3] );
        
        %%% Primary Specs
        
        gui.PrimaryText = uicontrol( 'Style', 'text', ...
            'Parent', controlLayout, ...
            'String', 'Primary Specifications: ', ...
            'FontSize', 9, 'FontWeight', 'bold');
        
        PrimaryLayout = uix.Grid( 'Parent', controlLayout, ...
            'Padding', 3, 'Spacing', 3 );
        
        gui.LengthText = uicontrol( 'Style', 'text', ...
            'Parent', PrimaryLayout, ...
            'String', 'Dist from Pivot to Roller Center (in)');
        
        gui.SheaveAngleText = uicontrol( 'Style', 'text', ...
            'Parent', PrimaryLayout, ...
            'String', 'Sheave Angle: ');
        
        gui.SpringRateText = uicontrol( 'Style', 'text', ...
            'Parent', PrimaryLayout, ...
            'String', 'Spring Rate (lb/in)');
        
        gui.FreeLengthText = uicontrol( 'Style', 'text', ...
            'Parent', PrimaryLayout, ...
            'String', 'Spring Free Length (in): ');
        
        gui.CompLengthText = uicontrol( 'Style', 'text', ...
            'Parent', PrimaryLayout, ...
            'String', 'Spring Compressed Length (in): ');
        
        gui.Length = uicontrol( 'Style', 'edit', ...
            'Parent', PrimaryLayout, 'String', '1.25');
        
        gui.SheaveAngle = uicontrol( 'Style', 'edit', ...
            'Parent', PrimaryLayout, 'String', '11');
        
        gui.SpringRate = uicontrol( 'Style', 'edit', ...
            'Parent', PrimaryLayout, 'String', '55');
        
        gui.FreeLength = uicontrol( 'Style', 'edit', ...
            'Parent', PrimaryLayout, 'String', '3.07');
        
        gui.CompLength = uicontrol( 'Style', 'edit', ...
            'Parent', PrimaryLayout, 'String', 2.02 - sh_disp);
        
        set( PrimaryLayout, 'Heights', [-1 -1 -1 -1 -1], 'Widths', [-1 -1] );
        
        %%% Secondary Specs
        
        gui.SecondaryText = uicontrol( 'Style', 'text', ...
            'Parent', controlLayout, ...
            'String', 'Secondary Specifications: ', ...
            'FontSize', 9, 'FontWeight', 'bold');
                
        SecondaryLayout = uix.Grid( 'Parent', controlLayout, ...
            'Padding', 3, 'Spacing', 3 );
        
        gui.HelixText = uicontrol( 'Style', 'text', ...
            'Parent', SecondaryLayout, ...
            'String', 'Select Helix Type/Angle: ');
        
        gui.HelixRadiusText = uicontrol( 'Style', 'text', ...
            'Parent', SecondaryLayout, ...
            'String', 'Helix Radius (in): ');
        
        gui.RampText = uicontrol( 'Style', 'text', ...
            'Parent', SecondaryLayout, ...
            'String', 'Select Ramp Type: ');
        
        gui.IdleText = uicontrol( 'Style', 'text', ...
            'Parent', SecondaryLayout, ...
            'String', 'Ramp Idle Angle: ');
        
        gui.SheaveAngle2Text = uicontrol( 'Style', 'text', ...
            'Parent', SecondaryLayout, ...
            'String', 'Sheave Angle: ');
        
        gui.SpringRate2Text = uicontrol( 'Style', 'text', ...
            'Parent', SecondaryLayout, ...
            'String', 'Spring Rate (lb/in): ');
        
        gui.FreeLength2Text = uicontrol( 'Style', 'text', ...
            'Parent', SecondaryLayout, ...
            'String', 'Spring Free Length (in): ');
        
        gui.CompLength2Text = uicontrol( 'Style', 'text', ...
            'Parent', SecondaryLayout, ...
            'String', 'Spring Compressed Length (in): ');
        
        gui.TPreloadText = uicontrol( 'Style', 'text', ...
            'Parent', SecondaryLayout, ...
            'String', 'Spring Torsional Preload: ');
        
        gui.HelixSelect = uicontrol( 'Style', 'popupmenu', ...
            'Parent', SecondaryLayout, 'String', helixList(:), ...
            'Value', 1, 'Callback', @onHelixSelect);
        
        gui.HelixRadius = uicontrol( 'Style', 'edit', ...
            'Parent', SecondaryLayout, 'String', '1.625');
        
        gui.RampSelect = uicontrol( 'Style', 'popupmenu', ...
            'Parent', SecondaryLayout, 'String', rampList(:), ...
            'Value', 1, 'Callback', @onRampSelect);
        
        gui.IdleAngle = uicontrol( 'Style', 'edit', ...
            'Parent', SecondaryLayout, 'String', '9');
        
        gui.SheaveAngle2 = uicontrol( 'Style', 'edit', ...
            'Parent', SecondaryLayout, 'String', '12');
        
        gui.SpringRate2 = uicontrol( 'Style', 'edit', ...
            'Parent', SecondaryLayout, 'String', '15');
        
        gui.FreeLength2 = uicontrol( 'Style', 'edit', ...
            'Parent', SecondaryLayout, 'String', '3.5');
        
        gui.CompLength2 = uicontrol( 'Style', 'edit', ...
            'Parent', SecondaryLayout, 'String', 2.25 - sh_disp);
        
        gui.TPreload = uicontrol( 'Style', 'edit', ...
            'Parent', SecondaryLayout, 'String', '0.05');
        
        set( SecondaryLayout, 'Heights', [-1 -1 -1 -1 -1 -1 -1 -1 -1], 'Widths', [-1 -1] );
        
        %%%
        
        set( controlLayout, 'Heights', [-1 -1 -1 -1 -1 -1 -1] );
        
end

end

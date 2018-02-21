class InspectorView extends UIElement {
    RectangleUI inspector;

    private TextUI identifier, mass, volume, charge, velocity, acceleration, bearing;

    InspectorView() {
        super();

        inspector = uiFactory.createRectOutlined(width - 400, 42, 358, 568, color(38, 38, 172), color(76, 89, 255), 6);
        
            identifier = uiFactory.createText(0, 32, 358, 200, color(255), "Neutron", CENTER);
            // TextUI identifier = uiFactory.createText(0, 0, 358, 200, color(255), "Electron", CENTER);
            identifier.setTextSize(72);
            inspector.appendChild(identifier);

            TextUI fundamentalTitle = uiFactory.createText(38, 140, 358, 200, color(255), "Fundamental Properties", LEFT);
            fundamentalTitle.setTextSize(24);
            inspector.appendChild(fundamentalTitle);

            RectangleUI fundamentalGroup = uiFactory.createRectOutlined(28, 171, 302, 150, color(70), color(76, 89, 255), 3);

                TextUI massParent = uiFactory.createText(10, 13, 200, 100, color(10), "Mass", LEFT);
                    mass = uiFactory.createText(0, 18, 200, 100, color(255), "9.11e-31 kg", LEFT);
                    massParent.appendChild(mass);
                fundamentalGroup.appendChild(massParent);
                
                TextUI volumeParent = uiFactory.createText(10, 57, 200, 100, color(10), "Volume", LEFT);
                    volume = uiFactory.createText(0, 18, 200, 100, color(255), "2.7e-27 m^3", LEFT);
                    volumeParent.appendChild(volume);
                fundamentalGroup.appendChild(volumeParent);

                TextUI chargeParent = uiFactory.createText(10, 101, 200, 100, color(10), "Charge", LEFT);
                    charge = uiFactory.createText(0, 18, 200, 100, color(255), "1.6e-19 C", LEFT);
                    chargeParent.appendChild(charge);
                fundamentalGroup.appendChild(chargeParent);

            inspector.appendChild(fundamentalGroup);

            TextUI instanceTitle = uiFactory.createText(38, 332, 358, 200, color(255), "Instance Properties", LEFT);
            instanceTitle.setTextSize(24);
            inspector.appendChild(instanceTitle);

            RectangleUI instanceGroup = uiFactory.createRectOutlined(28, 362, 302, 150, color(70), color(76, 89, 255), 3);

                TextUI velocityParent = uiFactory.createText(10, 13, 200, 100, color(10), "Velocity", LEFT);
                    velocity = uiFactory.createText(0, 18, 200, 100, color(255), "9.11e-31 kg", LEFT);
                    velocityParent.appendChild(velocity);
                instanceGroup.appendChild(velocityParent);
                
                TextUI accelerationParent = uiFactory.createText(10, 57, 200, 100, color(10), "Acceleration", LEFT);
                    acceleration = uiFactory.createText(0, 18, 200, 100, color(255), "2.7e-27 m^3", LEFT);
                    accelerationParent.appendChild(acceleration);
                instanceGroup.appendChild(accelerationParent);

                TextUI bearingParent = uiFactory.createText(10, 101, 200, 100, color(10), "Bearing", LEFT);
                    bearing = uiFactory.createText(0, 18, 200, 100, color(255), "1.6e-19 C", LEFT);
                    bearingParent.appendChild(bearing);
                instanceGroup.appendChild(bearingParent);

            inspector.appendChild(instanceGroup);

        appendChild(inspector);

        hide();
    }

    void updateDisplay() {
        if (!active) return;
        
        Particle target = selectionManager.getObjectFromSelection();
        if (target == null) {
            hide();
            return;
        }

        identifier.setText(target.getName());

        mass.setText(target.mass + "kg");
        volume.setText(target.r + "m^3");
        charge.setText(target.charge + "C");
        velocity.setText(target.velocity.mag() + "ms^-1");
        acceleration.setText(target.acceleration.mag() + "ms^-2");

        PVector directionFormat = target.velocity.copy().normalize();
        directionFormat.x = roundToDP(directionFormat.x, 3);
        directionFormat.y = roundToDP(directionFormat.y, 3);
        directionFormat.z = roundToDP(directionFormat.z, 3);
        bearing.setText("" + directionFormat);
    }
}
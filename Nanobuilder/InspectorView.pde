class InspectorView extends UIElement {
    RectangleUI inspector;

    InspectorView() {
        super();

        inspector = uiFactory.createRectOutlined(width - 400, 42, 358, 568, color(38, 38, 172), color(76, 89, 255), 6);
            TextUI title = uiFactory.createText(0, 22, 358, 200, color(255), "Neutron", CENTER);
            // TextUI title = uiFactory.createText(0, 0, 358, 200, color(255), "Electron", CENTER);
            title.setTextSize(72);
            inspector.appendChild(title);

            TextUI fundamentalTitle = uiFactory.createText(38, 116, 358, 200, color(255), "Fundamental Properties", LEFT);
            fundamentalTitle.setTextSize(24);
            inspector.appendChild(fundamentalTitle);

            RectangleUI fundamentalGroup = uiFactory.createRectOutlined(28, 156, 302, 150, color(70), color(76, 89, 255), 3);

                TextUI massParent = uiFactory.createText(10, 8, 200, 100, color(10), "Mass", LEFT);
                    TextUI massChild = uiFactory.createText(0, 18, 200, 100, color(255), "9.11e-31 kg", LEFT);
                    massParent.appendChild(massChild);
                fundamentalGroup.appendChild(massParent);
                
                TextUI volumeParent = uiFactory.createText(10, 52, 200, 100, color(10), "Volume", LEFT);
                    TextUI volumeChild = uiFactory.createText(0, 18, 200, 100, color(255), "2.7e-27 m^3", LEFT);
                    volumeParent.appendChild(volumeChild);
                fundamentalGroup.appendChild(volumeParent);

                TextUI chargeParent = uiFactory.createText(10, 96, 200, 100, color(10), "Charge", LEFT);
                    TextUI chargeChild = uiFactory.createText(0, 18, 200, 100, color(255), "1.6e-19 C", LEFT);
                    chargeParent.appendChild(chargeChild);
                fundamentalGroup.appendChild(chargeParent);

            inspector.appendChild(fundamentalGroup);

            TextUI instanceTitle = uiFactory.createText(38, 312, 358, 200, color(255), "Instance Properties", LEFT);
            instanceTitle.setTextSize(24);
            inspector.appendChild(instanceTitle);

            RectangleUI instanceGroup = uiFactory.createRectOutlined(28, 352, 302, 150, color(70), color(76, 89, 255), 3);

                TextUI velocityParent = uiFactory.createText(10, 8, 200, 100, color(10), "Velocity", LEFT);
                    TextUI velocityChild = uiFactory.createText(0, 18, 200, 100, color(255), "9.11e-31 kg", LEFT);
                    velocityParent.appendChild(velocityChild);
                instanceGroup.appendChild(velocityParent);
                
                TextUI accelerationParent = uiFactory.createText(10, 52, 200, 100, color(10), "Acceleration", LEFT);
                    TextUI accelerationChild = uiFactory.createText(0, 18, 200, 100, color(255), "2.7e-27 m^3", LEFT);
                    accelerationParent.appendChild(accelerationChild);
                instanceGroup.appendChild(accelerationParent);

                TextUI bearingParent = uiFactory.createText(10, 96, 200, 100, color(10), "Bearing", LEFT);
                    TextUI bearingChild = uiFactory.createText(0, 18, 200, 100, color(255), "1.6e-19 C", LEFT);
                    bearingParent.appendChild(bearingChild);
                instanceGroup.appendChild(bearingParent);

            inspector.appendChild(instanceGroup);

        inspector.hide();

        appendChild(inspector);
    }
}
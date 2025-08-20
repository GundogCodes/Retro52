//  ContentView.swift
//  Retro52 Watch App
//
//  Created by Gunish Sharma on 2025-08-18.
//

import SwiftUI
import WatchKit

struct ContentView: View {
    @State private var display = "0"
    @State private var previousValue: Double = 0
    @State private var currentOperation: String? = nil
    @State private var waitingForInput = false
    @State private var hasDecimal = false
    @State private var isAnimating = false
    @State private var showDate = true
    @State private var showBootScreen = true
    @State private var currentTheme = 0
    @State private var showThemeHint = true
    @State private var crownOffset: CGFloat = 0
    
    let themes = [
        CalculatorTheme(
            name: "Classic Green",
            background: Color.black,
            displayBackground: Color(red: (0.3 * 0.5 + 0.0 * 0.5), green: (0.3 * 0.5 + 1.0 * 0.5), blue: (0.3 * 0.5 + 0.0 * 0.5)),
            displayText: Color.black,
            headerText: Color.white,
            headerAccent: Color.blue,
            buttonBackground: Color(red: 50/255, green: 50/255, blue: 50/255),
            buttonText: Color.white,
            operationText: Color(red: 1.0, green: 0.27, blue: 0.0)
        ),
        CalculatorTheme(
            name: "Retro Amber",
            background: Color(red: 0.1, green: 0.05, blue: 0.0),
            displayBackground: Color(red: 1.0, green: 0.65, blue: 0.0),
            displayText: Color.black,
            headerText: Color(red: 1.0, green: 0.8, blue: 0.4),
            headerAccent: Color(red: 1.0, green: 0.5, blue: 0.0),
            buttonBackground: Color(red: 0.3, green: 0.2, blue: 0.1),
            buttonText: Color(red: 1.0, green: 0.8, blue: 0.4),
            operationText: Color(red: 1.0, green: 0.3, blue: 0.0)
        ),
        CalculatorTheme(
            name: "Neon Red",
            background: Color(red: 0.1, green: 0.0, blue: 0.0),
            displayBackground: Color(red: 1.0, green: 0.2, blue: 0.2),
            displayText: Color.white,
            headerText: Color(red: 1.0, green: 0.4, blue: 0.4),
            headerAccent: Color(red: 1.0, green: 0.0, blue: 0.5),
            buttonBackground: Color(red: 0.3, green: 0.1, blue: 0.1),
            buttonText: Color(red: 1.0, green: 0.6, blue: 0.6),
            operationText: Color(red: 1.0, green: 0.0, blue: 0.0)
        ),
        CalculatorTheme(
            name: "Ice Blue",
            background: Color(red: 0.0, green: 0.05, blue: 0.1),
            displayBackground: Color(red: 0.2, green: 0.7, blue: 1.0),
            displayText: Color.black,
            headerText: Color(red: 0.6, green: 0.8, blue: 1.0),
            headerAccent: Color(red: 0.0, green: 0.5, blue: 1.0),
            buttonBackground: Color(red: 0.1, green: 0.2, blue: 0.3),
            buttonText: Color(red: 0.7, green: 0.9, blue: 1.0),
            operationText: Color(red: 0.0, green: 0.4, blue: 1.0)
        ),
        CalculatorTheme(
            name: "Stainless Steel",
            background: .white,
            displayBackground: Color(red: 0.2, green: 0.7, blue: 1.0),
            displayText: Color.black,
            headerText: Color(red: 0.6, green: 0.8, blue: 1.0),
            headerAccent: Color(red: 0.0, green: 0.5, blue: 1.0),
            buttonBackground: .white,
            buttonText: .blue,
            operationText: Color(red: 0.0, green: 0.4, blue: 1.0)
        ),
        CalculatorTheme(
            name: "Vintage Purple",
            background: Color(red: 0.1, green: 0.0, blue: 0.1),
            displayBackground: Color(red: 0.8, green: 0.4, blue: 1.0),
            displayText: Color.black,
            headerText: Color(red: 0.9, green: 0.7, blue: 1.0),
            headerAccent: Color(red: 0.6, green: 0.0, blue: 1.0),
            buttonBackground: Color(red: 0.2, green: 0.1, blue: 0.3),
            buttonText: Color(red: 0.9, green: 0.7, blue: 1.0),
            operationText: Color(red: 0.8, green: 0.2, blue: 1.0)
        ),
        CalculatorTheme(
            name: "Matrix Green",
            background: Color.black,
            displayBackground: Color(red: 0.0, green: 0.8, blue: 0.0),
            displayText: Color.black,
            headerText: Color(red: 0.0, green: 1.0, blue: 0.0),
            headerAccent: Color(red: 0.2, green: 1.0, blue: 0.2),
            buttonBackground: Color(red: 0.0, green: 0.15, blue: 0.0),
            buttonText: Color(red: 0.0, green: 0.9, blue: 0.0),
            operationText: Color(red: 0.4, green: 1.0, blue: 0.4)
        )
    ]
    
    var currentThemeData: CalculatorTheme {
        themes[currentTheme]
    }
    
    let buttons = [
        ["C", "±", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]
    
    var body: some View {
        ZStack {
            if showBootScreen {
                BootScreenView {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showBootScreen = false
                    }
                }
            } else {
                calculatorView
            }
        }
    }
    
    var calculatorView: some View {
        ZStack {
            currentThemeData.background.ignoresSafeArea(.all)
            
            VStack(spacing: 1) {
                headerSection
                    
                
                displaySection
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.gray)
                    .clipShape(.capsule)
                    .padding(.horizontal, 4)

                buttonGrid
                
                Spacer(minLength: 1)
            }
            .padding(.horizontal, 2)
            .gesture(swipeGesture)
            .onAppear {
                // Show theme hint for 3 seconds after boot screen
                if showThemeHint {
                    display = "Swipe to change theme"
                    showDate = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            if showThemeHint {
                                display = "0"
                                showDate = true
                                showThemeHint = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack(spacing: 2) {
            VStack(spacing: 2) {
                BatteryIndicator()
                
                Text("Synthio")
                    .foregroundStyle(currentThemeData.headerText).bold()
                    .font(.system(size: 12))
            }
            
            Spacer()
            
            VStack(spacing: 0) {
                Text("Water Resistant")
                Text("Alarm Chronos")
            }
            .font(.system(size: 7))
            .foregroundColor(.blue)
            
            Spacer()
            
            Text("GS")
                .padding(.horizontal, 6)
                .padding(.vertical, 1)
                .font(.system(size: 8))
                .foregroundColor(
                    currentThemeData.name == "Classic Green" ? .yellow : currentThemeData.headerAccent
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(
                            currentThemeData.name == "Classic Green" ? .yellow : currentThemeData.headerAccent,
                            lineWidth: 1.2
                        )
                )
        }
        .font(.system(size: 8))
        .padding(.horizontal, 4)
    }
    
    private var displaySection: some View {
        HStack(spacing: 2) {
            HStack {
                // Left side with display text and cursor together
                HStack(spacing: 0) {
                    Text(display)
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundColor(currentThemeData.displayText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                    
                    BlinkingCursor(color: currentThemeData.displayText)
                }
                
                Spacer()
                
                // Right side with date
                if showDate {
                    Text(Date().formatted(.dateTime.month(.abbreviated).day()))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(currentThemeData.displayText.opacity(0.7))
                        .transition(.opacity)
                        .padding(.horizontal, 5)
                }
            }
            .frame(height: 32)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
            .background(currentThemeData.displayBackground)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(.darkGray), lineWidth: 1.5)
            )
            
            VStack(spacing: 0.5) {
                // Extended list for smooth scrolling effect
                Text("G").rotationEffect(.degrees(270))
                Text("•").rotationEffect(.degrees(270))
                Text("5").rotationEffect(.degrees(270))
                Text("2").rotationEffect(.degrees(270))
                Text("0").rotationEffect(.degrees(270))
                Text("2").rotationEffect(.degrees(270))
                Text("•").rotationEffect(.degrees(270))
                Text("2").rotationEffect(.degrees(270))
                Text("5").rotationEffect(.degrees(270))
                Text("•").rotationEffect(.degrees(270))
                Text("O").rotationEffect(.degrees(270))
                Text("R").rotationEffect(.degrees(270))
                Text("T").rotationEffect(.degrees(270))
                Text("E").rotationEffect(.degrees(270))
                Text("R").rotationEffect(.degrees(270))
                Text("•").rotationEffect(.degrees(270))
                Text("O").rotationEffect(.degrees(270))
                Text("I").rotationEffect(.degrees(270))
                Text("H").rotationEffect(.degrees(270))
                Text("T").rotationEffect(.degrees(270))
                Text("N").rotationEffect(.degrees(270))
                Text("Y").rotationEffect(.degrees(270))
                Text("S").rotationEffect(.degrees(270))
                Text("•").rotationEffect(.degrees(270))
                Text("S").rotationEffect(.degrees(270))
                Text("G").rotationEffect(.degrees(270))
            }
            .font(.system(size: 7, weight: .bold, design: .monospaced))
            .foregroundColor(currentThemeData.headerText)
            .multilineTextAlignment(.center)
            .frame(width: 10)
            .offset(y: crownOffset)
            .focusable()
            .digitalCrownRotation($crownOffset, from: -100, through: 100, by: 1, sensitivity: .medium, isContinuous: true, isHapticFeedbackEnabled: true)
            .onChange(of: crownOffset) { oldValue, newValue in
                let delta = abs(newValue - oldValue)
                if delta > 5 {
                    WKInterfaceDevice.current().play(.click)
                }
                
                // Keep the offset within reasonable bounds to create looping effect
                if newValue > 100 {
                    crownOffset = -100
                } else if newValue < -100 {
                    crownOffset = 100
                }
            }
            .frame(width: 10, height: 28)
            .background(Color.black.opacity(0.4))
            .cornerRadius(2)
            .clipped()
        }
        .padding(.horizontal, 4)
    }
    
    private var buttonGrid: some View {
        VStack(spacing: 1) {
            ForEach(Array(buttons.enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: 1) {
                    ForEach(Array(row.enumerated()), id: \.offset) { colIndex, symbol in
                        CalculatorButton(
                            symbol: symbol,
                            buttonType: getButtonType(symbol),
                            isSpecialWidth: symbol == "0" && rowIndex == 4,
                            theme: currentThemeData,
                            isSelected: currentOperation == symbol
                        ) {
                            buttonTapped(symbol)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 1)
    }
    
    private var swipeGesture: some Gesture {
        DragGesture()
            .onEnded { gesture in
                let threshold: CGFloat = 50
                
                if gesture.translation.width > threshold {
                    // Swipe right - previous theme
                    if showThemeHint {
                        showThemeHint = false
                        display = "0"
                        showDate = true
                    }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentTheme = (currentTheme - 1 + themes.count) % themes.count
                    }
                    WKInterfaceDevice.current().play(.click)
                } else if gesture.translation.width < -threshold {
                    // Swipe left - next theme
                    if showThemeHint {
                        showThemeHint = false
                        display = "0"
                        showDate = true
                    }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentTheme = (currentTheme + 1) % themes.count
                    }
                    WKInterfaceDevice.current().play(.click)
                }
            }
    }
    
    // MARK: - Calculator Logic
    
    func getButtonType(_ symbol: String) -> ButtonType {
        switch symbol {
        case "C":
            return .clear
        case "÷", "×", "−", "+", "=":
            return .operation
        case "±", "%":
            return .function
        default:
            return .number
        }
    }
    
    func buttonTapped(_ symbol: String) {
        // Dismiss theme hint if user starts interacting
        if showThemeHint {
            showThemeHint = false
            display = "0"
            showDate = true
        }
        
        if symbol == "=" {
            WKInterfaceDevice.current().play(.retry)
        } else {
            WKInterfaceDevice.current().play(.click)
        }
        
        withAnimation(.easeOut(duration: 0.3)) {
            showDate = false
        }
        
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isAnimating = false
        }
        
        switch symbol {
        case "C":
            clear()
        case "±":
            toggleSign()
        case "%":
            percentage()
        case "÷", "×", "−", "+":
            performOperation(symbol)
        case "=":
            calculateResult()
        case ".":
            addDecimal()
        default:
            inputNumber(symbol)
        }
    }
    
    func clear() {
        display = "0"
        previousValue = 0
        currentOperation = nil
        waitingForInput = false
        hasDecimal = false
        
        withAnimation(.easeIn(duration: 0.5)) {
            showDate = true
        }
    }
    
    func toggleSign() {
        if display != "0" {
            if display.hasPrefix("-") {
                display = String(display.dropFirst())
            } else {
                display = "-" + display
            }
        }
    }
    
    func percentage() {
        if let value = Double(display) {
            let result = value / 100
            display = String(result)
            hasDecimal = display.contains(".")
        }
    }
    
    func performOperation(_ operation: String) {
        if let currentValue = Double(display) {
            if let previousOp = currentOperation, !waitingForInput {
                let result = calculate(previousValue, currentValue, previousOp)
                display = formatResult(result)
                previousValue = result
            } else {
                previousValue = currentValue
            }
        }
        
        currentOperation = operation
        waitingForInput = true
        hasDecimal = false
    }
    
    func calculateResult() {
        guard let operation = currentOperation,
              let currentValue = Double(display) else { return }
        
        let result = calculate(previousValue, currentValue, operation)
        display = formatResult(result)
        
        previousValue = result
        currentOperation = nil
        waitingForInput = true
        hasDecimal = display.contains(".")
    }
    
    func calculate(_ first: Double, _ second: Double, _ operation: String) -> Double {
        switch operation {
        case "+":
            return first + second
        case "−":
            return first - second
        case "×":
            return first * second
        case "÷":
            return second != 0 ? first / second : 0
        default:
            return second
        }
    }
    
    func addDecimal() {
        if waitingForInput {
            display = "0."
            waitingForInput = false
            hasDecimal = true
        } else if !hasDecimal {
            display += "."
            hasDecimal = true
        }
    }
    
    func inputNumber(_ number: String) {
        if waitingForInput {
            display = number
            waitingForInput = false
            hasDecimal = false
        } else {
            if display == "0" {
                display = number
            } else {
                if display.count < 12 {
                    display += number
                }
            }
        }
    }
    
    func formatResult(_ value: Double) -> String {
        if abs(value) >= 1e9 || (abs(value) < 1e-6 && value != 0) {
            return String(format: "%.2e", value)
        }
        
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            let formatted = String(format: "%.6f", value)
            return formatted.trimmingCharacters(in: CharacterSet(charactersIn: "0")).trimmingCharacters(in: CharacterSet(charactersIn: "."))
        }
    }
}

// MARK: - Supporting Structures

enum ButtonType {
    case number, operation, function, clear
}

struct CalculatorButton: View {
    let symbol: String
    let buttonType: ButtonType
    let isSpecialWidth: Bool
    let theme: CalculatorTheme
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 1) {
                Text(symbol)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(foregroundColor(for: buttonType))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(minHeight: 26)
                    .background(backgroundColor(for: buttonType))
                    .clipShape(.capsule)
                    .scaleEffect(isPressed ? 1.05 : 1.0)
                
                // Decorative line for non-operation buttons
                if buttonType != .operation {
                    Rectangle()
                        .frame(width: 28, height: 0.5)
                        .foregroundColor(theme.buttonText.opacity(0.6))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: isSpecialWidth ? .infinity : nil)
        .frame(maxHeight: 32)
    }
    
    func foregroundColor(for type: ButtonType) -> Color {
        switch type {
        case .operation:
            return isSelected ? theme.displayBackground : theme.operationText
        default:
            return theme.buttonText
        }
    }
    
    func backgroundColor(for type: ButtonType) -> Color {
        switch type {
        case .operation:
            return isSelected ? theme.operationText : theme.buttonBackground
        default:
            return theme.buttonBackground
        }
    }
}

struct BlinkingCursor: View {
    let color: Color
    @State private var isVisible = true
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 1.5, height: 12)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.6).repeatForever()) {
                    isVisible.toggle()
                }
            }
    }
    
    init(color: Color = .black) {
        self.color = color
    }
}

struct BatteryIndicator: View {
    @State private var batteryLevel: Float = 0.0
    
    var body: some View {
        HStack(spacing: 1) {
            Rectangle()
                .fill(batteryColor)
                .frame(width: max(1, CGFloat(batteryLevel) * 16), height: 2.5)
            
            if CGFloat(batteryLevel) * 16 < 16 {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 16 - CGFloat(batteryLevel) * 16, height: 2.5)
            }
        }
        .frame(width: 16, height: 2.5)
        .overlay(
            RoundedRectangle(cornerRadius: 1)
                .stroke(Color.white, lineWidth: 0.4)
        )
        .onAppear {
            updateBatteryLevel()
            Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                updateBatteryLevel()
            }
        }
    }
    
    private func updateBatteryLevel() {
        batteryLevel = WKInterfaceDevice.current().batteryLevel
    }
    
    private var batteryColor: Color {
        if batteryLevel > 0.5 {
            return .green
        } else if batteryLevel > 0.2 {
            return .yellow
        } else {
            return .red
        }
    }
}

struct BootScreenView: View {
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            VStack(spacing: 8) {
                Text("Synthio")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
                
                Text("CALCULATOR")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.green.opacity(0.7))
                
                HStack(spacing: 1.5) {
                    ForEach(0..<6) { index in
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: 2.5, height: 2.5)
                            .opacity(0.3)
                    }
                }
                .padding(.top, 8)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onComplete()
            }
        }
    }
}

struct CalculatorTheme {
    let name: String
    let background: Color
    let displayBackground: Color
    let displayText: Color
    let headerText: Color
    let headerAccent: Color
    let buttonBackground: Color
    let buttonText: Color
    let operationText: Color
}

#Preview {
    ContentView()
}

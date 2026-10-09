#if canImport(UIKit)
import SwiftUI

struct ClaudeProjectIconPicker: View {
    let initialSymbol: String
    let initialColor: String
    let back: () -> Void
    let save: (String, String) -> Void
    @State private var symbol = "rectangle.stack"
    @State private var color = "Default"
    @State private var query = ""
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Text("Project icon").font(.system(size: 17, weight: .semibold))
                HStack {
                    Button(action: back) { Image(systemName: "chevron.left").font(.system(size: 23, weight: .light)).frame(width: 44, height: 44) }.glassEffect(in: .circle).accessibilityLabel("Back to new project").accessibilityIdentifier("project.icons.back")
                    Spacer()
                    Button { save(symbol, color) } label: { Image(systemName: "checkmark").font(.system(size: 23, weight: .light)).foregroundStyle(.black).frame(width: 44, height: 44).background(.white, in: .circle) }.accessibilityLabel("Save project icon").accessibilityIdentifier("project.icons.save")
                }
            }.frame(height: 48)
            VStack(spacing: 16) {
                HStack(spacing: 4) { ForEach(Array(ProjectState.iconColors.prefix(10)), id: \.self) { swatch($0) } }
                HStack(spacing: 4) { Color.clear.frame(width: 32, height: 32); ForEach(Array(ProjectState.iconColors.suffix(9)), id: \.self) { swatch($0) } }
            }
            TextField("Search for an icon...", text: $query).font(.system(size: 16)).padding(.horizontal, 16).frame(height: 48).background(ClaudePalette.panel, in: .capsule).overlay { Capsule().stroke(.white.opacity(0.12), lineWidth: 0.5) }.padding(.top, 12).accessibilityIdentifier("project.icons.search")
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 16) {
                    ForEach(ProjectIconOption.matching(query)) { option in
                        Button { symbol = option.symbol } label: {
                            Group { if option.symbol == "rectangle.stack" { ProjectOutlineIcon() } else { Image(systemName: option.symbol).resizable().scaledToFit() } }
                                .frame(width: 21, height: 21).foregroundStyle(ProjectIconColors.value(color)).frame(width: 40, height: 40).background(ClaudePalette.panel, in: .circle).overlay { if option.symbol == symbol { Circle().stroke(ClaudePalette.ink, lineWidth: 2) } }
                        }.accessibilityLabel(option.name).accessibilityIdentifier("project.icons." + option.symbol).accessibilityAddTraits(option.symbol == symbol ? .isSelected : [])
                    }
                }.padding(.top, 10).padding(.bottom, 16)
            }.scrollIndicators(.hidden)
        }.padding(.horizontal, 16).padding(.top, 16).background(ClaudePalette.background).onAppear { symbol = initialSymbol; color = initialColor }
    }
    private func swatch(_ name: String) -> some View {
        Button { color = name } label: { Circle().fill(name == "Default" ? ClaudePalette.panel : ProjectIconColors.value(name)).frame(width: 32, height: 32).overlay { if color == name { Image(systemName: "checkmark").font(.system(size: 16)).foregroundStyle(name == "Default" ? ClaudePalette.ink : .white) } } }.frame(maxWidth: .infinity).accessibilityLabel(name + " icon color").accessibilityIdentifier("project.icons.color." + name)
    }
}
enum ProjectIconColors {
    static func value(_ name: String) -> Color {
        let colors: [String: (Double, Double, Double)] = ["Gray": (0.58,0.58,0.55), "Coral": (0.89,0.36,0.37), "Orange": (0.94,0.39,0.15), "Gold": (0.8,0.54,0), "Green": (0.13,0.68,0.16), "Teal": (0.03,0.64,0.48), "Blue": (0.29,0.59,0.86), "Purple": (0.55,0.48,0.87), "Pink": (0.86,0.29,0.54), "Dark gray": (0.51,0.51,0.49), "Red": (0.88,0.2,0.24), "Dark orange": (0.8,0.28,0.08), "Ochre": (0.69,0.43,0), "Dark green": (0.03,0.6,0), "Dark teal": (0.02,0.56,0.39), "Dark blue": (0.2,0.51,0.87), "Violet": (0.46,0.36,0.85), "Magenta": (0.77,0.24,0.47)]
        guard let rgb = colors[name] else { return ClaudePalette.secondary }; return Color(red: rgb.0, green: rgb.1, blue: rgb.2)
    }
}
#endif

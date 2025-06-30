import SwiftUI

struct SkillsView: View {
    let skills = Skill.mockSkills

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Мои навыки")
                .font(.headline)
                .padding(.horizontal)

            ForEach(skills) { skill in
                SkillRow(skill: skill)
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
}

struct SkillRow: View {
    let skill: Skill

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(skill.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(Int(skill.level * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(skill.color)
                        .frame(width: geometry.size.width * skill.level, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

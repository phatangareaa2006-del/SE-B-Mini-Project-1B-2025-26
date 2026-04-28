import { useState } from "react";
import { Code, Plus, X, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Slider } from "@/components/ui/slider";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";

interface UserSkill {
  id: string;
  skill_id: string;
  proficiency_level: number | null;
  skill: {
    id: string;
    name: string;
    category: string | null;
  };
}

interface SkillsSectionProps {
  skills: UserSkill[];
  onAdd: (skillName: string, proficiencyLevel: number) => Promise<any>;
  onUpdate: (userSkillId: string, proficiencyLevel: number) => Promise<boolean>;
  onDelete: (userSkillId: string) => Promise<boolean>;
}

const commonSkills = [
  "JavaScript", "TypeScript", "Python", "Java", "C++", "React", "Node.js", "SQL",
  "AWS", "Docker", "Git", "Machine Learning", "Data Analysis", "HTML/CSS",
  "MongoDB", "PostgreSQL", "GraphQL", "REST API", "Figma", "Agile",
];

export const SkillsSection = ({
  skills,
  onAdd,
  onUpdate,
  onDelete,
}: SkillsSectionProps) => {
  const [isAdding, setIsAdding] = useState(false);
  const [newSkill, setNewSkill] = useState("");
  const [proficiency, setProficiency] = useState(3);
  const [saving, setSaving] = useState(false);
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const handleAdd = async () => {
    if (!newSkill.trim()) return;
    setSaving(true);
    const result = await onAdd(newSkill.trim(), proficiency);
    if (result) {
      setNewSkill("");
      setProficiency(3);
      setIsAdding(false);
    }
    setSaving(false);
  };

  const handleDelete = async (id: string) => {
    setDeletingId(id);
    await onDelete(id);
    setDeletingId(null);
  };

  const handleQuickAdd = async (skillName: string) => {
    setSaving(true);
    await onAdd(skillName, 3);
    setSaving(false);
  };

  const getProficiencyLabel = (level: number) => {
    switch (level) {
      case 1: return "Beginner";
      case 2: return "Elementary";
      case 3: return "Intermediate";
      case 4: return "Advanced";
      case 5: return "Expert";
      default: return "Intermediate";
    }
  };

  const existingSkillNames = skills.map((s) => s.skill?.name?.toLowerCase() || "");
  const suggestedSkills = commonSkills.filter(
    (s) => !existingSkillNames.includes(s.toLowerCase())
  );

  return (
    <>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle className="flex items-center gap-2">
            <Code className="h-5 w-5" />
            Skills
          </CardTitle>
          <Button variant="outline" size="sm" className="gap-1" onClick={() => setIsAdding(true)}>
            <Plus className="h-4 w-4" />
            Add
          </Button>
        </CardHeader>
        <CardContent>
          {skills.length === 0 ? (
            <div className="text-center py-8">
              <p className="text-muted-foreground italic mb-4">
                Add your technical and soft skills
              </p>
              <div className="flex flex-wrap gap-2 justify-center">
                {suggestedSkills.slice(0, 8).map((skill) => (
                  <Button
                    key={skill}
                    variant="outline"
                    size="sm"
                    onClick={() => handleQuickAdd(skill)}
                    disabled={saving}
                  >
                    <Plus className="h-3 w-3 mr-1" />
                    {skill}
                  </Button>
                ))}
              </div>
            </div>
          ) : (
            <div className="flex flex-wrap gap-2">
              {skills.map((userSkill) => (
                <Badge
                  key={userSkill.id}
                  variant="secondary"
                  className="px-3 py-1.5 text-sm group cursor-default"
                >
                  {userSkill.skill?.name}
                  {userSkill.proficiency_level && (
                    <span className="ml-2 opacity-60">
                      {"●".repeat(userSkill.proficiency_level)}
                      {"○".repeat(5 - userSkill.proficiency_level)}
                    </span>
                  )}
                  <button
                    className="ml-2 opacity-0 group-hover:opacity-100 transition-opacity hover:text-destructive"
                    onClick={() => handleDelete(userSkill.id)}
                    disabled={deletingId === userSkill.id}
                  >
                    {deletingId === userSkill.id ? (
                      <Loader2 className="h-3 w-3 animate-spin" />
                    ) : (
                      <X className="h-3 w-3" />
                    )}
                  </button>
                </Badge>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Add Skill Dialog */}
      <Dialog open={isAdding} onOpenChange={setIsAdding}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Add Skill</DialogTitle>
          </DialogHeader>
          <div className="space-y-6">
            <div>
              <Input
                value={newSkill}
                onChange={(e) => setNewSkill(e.target.value)}
                placeholder="Enter skill name..."
                onKeyDown={(e) => e.key === "Enter" && handleAdd()}
              />
            </div>

            <div>
              <div className="flex justify-between mb-2">
                <span className="text-sm text-muted-foreground">Proficiency Level</span>
                <span className="text-sm font-medium">{getProficiencyLabel(proficiency)}</span>
              </div>
              <Slider
                value={[proficiency]}
                onValueChange={(v) => setProficiency(v[0])}
                min={1}
                max={5}
                step={1}
              />
              <div className="flex justify-between text-xs text-muted-foreground mt-1">
                <span>Beginner</span>
                <span>Expert</span>
              </div>
            </div>

            {suggestedSkills.length > 0 && (
              <div>
                <span className="text-sm text-muted-foreground">Suggestions:</span>
                <div className="flex flex-wrap gap-2 mt-2">
                  {suggestedSkills.slice(0, 10).map((skill) => (
                    <Button
                      key={skill}
                      variant="ghost"
                      size="sm"
                      className="h-7 text-xs"
                      onClick={() => setNewSkill(skill)}
                    >
                      {skill}
                    </Button>
                  ))}
                </div>
              </div>
            )}

            <div className="flex gap-2 justify-end">
              <Button variant="outline" onClick={() => setIsAdding(false)}>
                Cancel
              </Button>
              <Button onClick={handleAdd} disabled={saving || !newSkill.trim()}>
                {saving ? <Loader2 className="h-4 w-4 mr-1 animate-spin" /> : null}
                Add Skill
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
};

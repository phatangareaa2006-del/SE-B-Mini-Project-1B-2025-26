import { User, Pencil } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useState } from "react";
import { Textarea } from "@/components/ui/textarea";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Loader2, X, Check } from "lucide-react";

interface AboutSectionProps {
  bio: string | null;
  onUpdate: (bio: string) => Promise<boolean>;
}

export const AboutSection = ({ bio, onUpdate }: AboutSectionProps) => {
  const [isEditing, setIsEditing] = useState(false);
  const [editBio, setEditBio] = useState(bio || "");
  const [saving, setSaving] = useState(false);

  const handleSave = async () => {
    setSaving(true);
    const success = await onUpdate(editBio);
    if (success) {
      setIsEditing(false);
    }
    setSaving(false);
  };

  return (
    <>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle className="flex items-center gap-2">
            <User className="h-5 w-5" />
            About
          </CardTitle>
          <Button
            variant="ghost"
            size="icon"
            onClick={() => {
              setEditBio(bio || "");
              setIsEditing(true);
            }}
          >
            <Pencil className="h-4 w-4" />
          </Button>
        </CardHeader>
        <CardContent>
          {bio ? (
            <p className="whitespace-pre-wrap text-sm leading-relaxed">{bio}</p>
          ) : (
            <p className="text-muted-foreground italic">
              Tell recruiters about yourself, your goals, and what makes you unique.
            </p>
          )}
        </CardContent>
      </Card>

      <Dialog open={isEditing} onOpenChange={setIsEditing}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>Edit About</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <Textarea
              value={editBio}
              onChange={(e) => setEditBio(e.target.value)}
              placeholder="Tell recruiters about yourself..."
              rows={6}
              className="resize-none"
            />
            <p className="text-xs text-muted-foreground">
              {editBio.length}/2000 characters
            </p>
            <div className="flex gap-2 justify-end">
              <Button variant="outline" onClick={() => setIsEditing(false)}>
                <X className="h-4 w-4 mr-1" />
                Cancel
              </Button>
              <Button onClick={handleSave} disabled={saving}>
                {saving ? (
                  <Loader2 className="h-4 w-4 mr-1 animate-spin" />
                ) : (
                  <Check className="h-4 w-4 mr-1" />
                )}
                Save
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
};

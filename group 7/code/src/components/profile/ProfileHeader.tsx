import { useState, useRef } from "react";
import {
  Camera,
  MapPin,
  Mail,
  Linkedin,
  Github,
  Globe,
  Pencil,
  X,
  Check,
  Loader2,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { useFileUpload } from "@/hooks/useFileUpload";

type Profile = Database["public"]["Tables"]["profiles"]["Row"];

interface ProfileHeaderProps {
  profile: Profile | null;
  onUpdate: (updates: Partial<Profile>) => Promise<boolean>;
  userId: string;
}

export const ProfileHeader = ({ profile, onUpdate, userId }: ProfileHeaderProps) => {
  const [isEditing, setIsEditing] = useState(false);
  const [editData, setEditData] = useState({
    full_name: profile?.full_name || "",
    headline: profile?.headline || "",
    bio: profile?.bio || "",
    location: profile?.location || "",
    linkedin_url: profile?.linkedin_url || "",
    github_url: profile?.github_url || "",
    website: profile?.website || "",
    is_available: profile?.is_available || false,
  });
  const [saving, setSaving] = useState(false);
  
  const avatarInputRef = useRef<HTMLInputElement>(null);
  const bannerInputRef = useRef<HTMLInputElement>(null);
  const { uploadFile, uploading } = useFileUpload();

  const getInitials = (name: string | null) => {
    if (!name) return "U";
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2);
  };

  const handleAvatarUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const url = await uploadFile(file, {
      bucket: "profile-uploads",
      folder: "avatars",
      userId,
      acceptedTypes: ["image/"],
      maxSizeMB: 5,
    });

    if (url) {
      await onUpdate({ avatar_url: url });
    }
  };

  const handleBannerUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const url = await uploadFile(file, {
      bucket: "profile-uploads",
      folder: "banners",
      userId,
      acceptedTypes: ["image/"],
      maxSizeMB: 10,
    });

    if (url) {
      await onUpdate({ banner_url: url });
    }
  };

  const handleSave = async () => {
    setSaving(true);
    const success = await onUpdate(editData);
    if (success) {
      setIsEditing(false);
    }
    setSaving(false);
  };

  const openEdit = () => {
    setEditData({
      full_name: profile?.full_name || "",
      headline: profile?.headline || "",
      bio: profile?.bio || "",
      location: profile?.location || "",
      linkedin_url: profile?.linkedin_url || "",
      github_url: profile?.github_url || "",
      website: profile?.website || "",
      is_available: profile?.is_available || false,
    });
    setIsEditing(true);
  };

  return (
    <>
      <div className="rounded-lg border bg-card overflow-hidden">
        {/* Banner */}
        <div className="h-32 sm:h-48 bg-gradient-to-r from-primary/20 via-accent/20 to-primary/20 relative group">
          {profile?.banner_url && (
            <img
              src={profile.banner_url}
              alt="Banner"
              className="w-full h-full object-cover"
            />
          )}
          <input
            ref={bannerInputRef}
            type="file"
            accept="image/*"
            className="hidden"
            onChange={handleBannerUpload}
          />
          <Button
            variant="secondary"
            size="icon"
            className="absolute bottom-2 right-2 h-8 w-8 opacity-0 group-hover:opacity-100 transition-opacity"
            onClick={() => bannerInputRef.current?.click()}
            disabled={uploading}
          >
            {uploading ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <Camera className="h-4 w-4" />
            )}
          </Button>
        </div>

        <div className="p-4 sm:p-6 pt-0">
          <div className="flex flex-col sm:flex-row gap-4 -mt-16 sm:-mt-12">
            {/* Avatar */}
            <div className="relative">
              <Avatar className="h-28 w-28 border-4 border-card">
                <AvatarImage src={profile?.avatar_url || ""} />
                <AvatarFallback className="text-2xl bg-primary text-primary-foreground">
                  {getInitials(profile?.full_name)}
                </AvatarFallback>
              </Avatar>
              <input
                ref={avatarInputRef}
                type="file"
                accept="image/*"
                className="hidden"
                onChange={handleAvatarUpload}
              />
              <Button
                variant="secondary"
                size="icon"
                className="absolute bottom-0 right-0 h-8 w-8 rounded-full"
                onClick={() => avatarInputRef.current?.click()}
                disabled={uploading}
              >
                {uploading ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  <Camera className="h-4 w-4" />
                )}
              </Button>
            </div>

            <div className="flex-1 sm:pt-14">
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                  <h1 className="text-2xl font-bold flex items-center gap-2 flex-wrap">
                    {profile?.full_name || "Your Name"}
                    {profile?.is_available && (
                      <Badge className="bg-green-500/20 text-green-600 dark:text-green-400 border-green-500/30">
                        Open to Work
                      </Badge>
                    )}
                  </h1>
                  <p className="text-muted-foreground">
                    {profile?.headline || "Add a headline to stand out"}
                  </p>
                </div>
                <Button variant="outline" className="gap-2 shrink-0" onClick={openEdit}>
                  <Pencil className="h-4 w-4" />
                  Edit Profile
                </Button>
              </div>

              {/* Quick Info */}
              <div className="flex flex-wrap gap-4 mt-4 text-sm text-muted-foreground">
                {profile?.location && (
                  <span className="flex items-center gap-1">
                    <MapPin className="h-4 w-4" />
                    {profile.location}
                  </span>
                )}
                {profile?.email && (
                  <span className="flex items-center gap-1">
                    <Mail className="h-4 w-4" />
                    {profile.email}
                  </span>
                )}
                {profile?.linkedin_url && (
                  <a
                    href={profile.linkedin_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-1 hover:text-primary transition-colors"
                  >
                    <Linkedin className="h-4 w-4" />
                    LinkedIn
                  </a>
                )}
                {profile?.github_url && (
                  <a
                    href={profile.github_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-1 hover:text-primary transition-colors"
                  >
                    <Github className="h-4 w-4" />
                    GitHub
                  </a>
                )}
                {profile?.website && (
                  <a
                    href={profile.website}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-1 hover:text-primary transition-colors"
                  >
                    <Globe className="h-4 w-4" />
                    Website
                  </a>
                )}
              </div>
            </div>
          </div>

          {/* Profile Completion */}
          <div className="mt-6 p-4 bg-muted rounded-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-medium">Profile Completion</span>
              <span className="text-sm text-muted-foreground">
                {profile?.profile_completion || 0}%
              </span>
            </div>
            <Progress value={profile?.profile_completion || 0} className="h-2" />
          </div>
        </div>
      </div>

      {/* Edit Dialog */}
      <Dialog open={isEditing} onOpenChange={setIsEditing}>
        <DialogContent className="max-w-lg max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Edit Profile</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <div>
              <Label htmlFor="full_name">Full Name</Label>
              <Input
                id="full_name"
                value={editData.full_name}
                onChange={(e) => setEditData({ ...editData, full_name: e.target.value })}
                placeholder="John Doe"
              />
            </div>
            <div>
              <Label htmlFor="headline">Headline</Label>
              <Input
                id="headline"
                value={editData.headline}
                onChange={(e) => setEditData({ ...editData, headline: e.target.value })}
                placeholder="Software Engineer | React Developer"
              />
            </div>
            <div>
              <Label htmlFor="bio">About</Label>
              <Textarea
                id="bio"
                value={editData.bio}
                onChange={(e) => setEditData({ ...editData, bio: e.target.value })}
                placeholder="Tell recruiters about yourself..."
                rows={4}
              />
            </div>
            <div>
              <Label htmlFor="location">Location</Label>
              <Input
                id="location"
                value={editData.location}
                onChange={(e) => setEditData({ ...editData, location: e.target.value })}
                placeholder="Mumbai, India"
              />
            </div>
            <div>
              <Label htmlFor="linkedin_url">LinkedIn URL</Label>
              <Input
                id="linkedin_url"
                value={editData.linkedin_url}
                onChange={(e) => setEditData({ ...editData, linkedin_url: e.target.value })}
                placeholder="https://linkedin.com/in/yourprofile"
              />
            </div>
            <div>
              <Label htmlFor="github_url">GitHub URL</Label>
              <Input
                id="github_url"
                value={editData.github_url}
                onChange={(e) => setEditData({ ...editData, github_url: e.target.value })}
                placeholder="https://github.com/username"
              />
            </div>
            <div>
              <Label htmlFor="website">Website</Label>
              <Input
                id="website"
                value={editData.website}
                onChange={(e) => setEditData({ ...editData, website: e.target.value })}
                placeholder="https://yourwebsite.com"
              />
            </div>
            <div className="flex items-center justify-between">
              <Label htmlFor="is_available">Open to Work</Label>
              <Switch
                id="is_available"
                checked={editData.is_available}
                onCheckedChange={(checked) => setEditData({ ...editData, is_available: checked })}
              />
            </div>
            <div className="flex gap-2 justify-end pt-4">
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

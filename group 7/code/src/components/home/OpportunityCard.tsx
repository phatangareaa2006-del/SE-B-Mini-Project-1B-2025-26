import { Heart, Calendar, MapPin, Users } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { toast } from "sonner";
import { format } from "date-fns";

interface OpportunityCardProps {
  id: string;
  title: string;
  organizerName?: string;
  organizerLogo?: string;
  imageUrl?: string;
  mode?: string;
  isFree?: boolean;
  location?: string;
  startDate?: string;
  endDate?: string;
  registrationDeadline?: string;
  prizePool?: number;
  stipendMin?: number;
  stipendMax?: number;
  tags?: string[];
  currentParticipants?: number;
  opportunityType: string;
  isSaved?: boolean;
  onSaveToggle?: () => void;
}

const OpportunityCard = ({
  id,
  title,
  organizerName,
  organizerLogo,
  imageUrl,
  mode,
  isFree = true,
  location,
  startDate,
  endDate,
  registrationDeadline,
  prizePool,
  stipendMin,
  stipendMax,
  tags = [],
  currentParticipants,
  opportunityType,
  isSaved = false,
  onSaveToggle,
}: OpportunityCardProps) => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [saved, setSaved] = useState(isSaved);
  const [saving, setSaving] = useState(false);

  const handleCardClick = () => {
    navigate(`/jobs/${id}`);
  };

  const handleSaveToggle = async (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    
    if (!user) {
      toast.error("Please sign in to save opportunities");
      return;
    }

    setSaving(true);
    try {
      if (saved) {
        const { error } = await supabase
          .from("saved_opportunities")
          .delete()
          .eq("opportunity_id", id)
          .eq("user_id", user.id);
        
        if (error) throw error;
        toast.success("Removed from saved");
      } else {
        const { error } = await supabase
          .from("saved_opportunities")
          .insert({ opportunity_id: id, user_id: user.id });
        
        if (error) throw error;
        toast.success("Saved successfully");
      }
      setSaved(!saved);
      onSaveToggle?.();
    } catch (error: any) {
      toast.error(error.message || "Failed to save");
    } finally {
      setSaving(false);
    }
  };

  const getModeColor = (mode?: string) => {
    switch (mode?.toLowerCase()) {
      case "online": return "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400";
      case "offline": return "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400";
      case "wfh": return "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400";
      case "hybrid": return "bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400";
      default: return "bg-muted text-muted-foreground";
    }
  };

  const formatCurrency = (amount: number) => {
    if (amount >= 100000) {
      return `₹${(amount / 100000).toFixed(1)} Lakh`;
    } else if (amount >= 1000) {
      return `₹${(amount / 1000).toFixed(0)}K`;
    }
    return `₹${amount}`;
  };

  const getTypeLabel = (type: string) => {
    const labels: Record<string, string> = {
      internship: "Internship",
      job: "Job",
      competition: "Competition",
      mock_test: "Mock Test",
      mentorship: "Mentorship",
      course: "Course",
    };
    return labels[type] || type;
  };

  return (
    <Card className="group overflow-hidden hover:shadow-xl transition-all duration-300 hover:-translate-y-1 border-border/50 bg-card cursor-pointer" onClick={handleCardClick}>
      <div className="relative aspect-[4/3] overflow-hidden">
        {imageUrl ? (
          <img
            src={imageUrl}
            alt={title}
            className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
          />
        ) : (
          <div className="w-full h-full bg-gradient-to-br from-primary/20 to-primary/40 flex items-center justify-center">
            <span className="text-4xl font-bold text-primary/50">
              {title.charAt(0).toUpperCase()}
            </span>
          </div>
        )}
        
        {/* Overlay with organizer info */}
        {organizerLogo && (
          <div className="absolute top-3 left-3 flex items-center gap-2 bg-background/90 backdrop-blur-sm rounded-lg px-2 py-1">
            <img src={organizerLogo} alt={organizerName} className="w-6 h-6 rounded" />
            <span className="text-xs font-medium truncate max-w-[100px]">{organizerName}</span>
          </div>
        )}
        
        {/* Save button */}
        <Button
          variant="ghost"
          size="icon"
          className={cn(
            "absolute top-3 right-3 bg-background/80 backdrop-blur-sm hover:bg-background",
            saved && "text-red-500"
          )}
          onClick={handleSaveToggle}
          disabled={saving}
        >
          <Heart className={cn("h-4 w-4", saved && "fill-current")} />
        </Button>

        {/* Prize/Stipend badge */}
        {(prizePool || stipendMin) && (
          <div className="absolute bottom-3 left-3 bg-gradient-to-r from-yellow-500 to-orange-500 text-white px-3 py-1 rounded-full text-sm font-semibold">
            {prizePool ? `Prize: ${formatCurrency(prizePool)}` : 
             stipendMax ? `${formatCurrency(stipendMin!)} - ${formatCurrency(stipendMax)}` :
             formatCurrency(stipendMin!)}
          </div>
        )}
      </div>

      <CardContent className="p-4">
        {/* Tags */}
        <div className="flex flex-wrap gap-2 mb-3">
          {mode && (
            <Badge variant="secondary" className={cn("text-xs", getModeColor(mode))}>
              {mode.toUpperCase()}
            </Badge>
          )}
          <Badge variant="secondary" className={cn(
            "text-xs",
            isFree ? "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400" : 
                     "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400"
          )}>
            {isFree ? "Free" : "Paid"}
          </Badge>
          <Badge variant="outline" className="text-xs">
            {getTypeLabel(opportunityType)}
          </Badge>
        </div>

        {/* Title */}
        <h3 className="font-semibold text-foreground line-clamp-2 mb-2 group-hover:text-primary transition-colors">
          {title}
        </h3>

        {/* Meta info */}
        <div className="space-y-1.5 text-xs text-muted-foreground">
          {location && (
            <div className="flex items-center gap-1.5">
              <MapPin className="h-3.5 w-3.5" />
              <span className="truncate">{location}</span>
            </div>
          )}
          {registrationDeadline && (
            <div className="flex items-center gap-1.5">
              <Calendar className="h-3.5 w-3.5" />
              <span>Deadline: {format(new Date(registrationDeadline), "MMM dd, yyyy")}</span>
            </div>
          )}
          {currentParticipants !== undefined && (
            <div className="flex items-center gap-1.5">
              <Users className="h-3.5 w-3.5" />
              <span>{currentParticipants.toLocaleString()} registered</span>
            </div>
          )}
        </div>

        {/* Custom tags */}
        {tags.length > 0 && (
          <div className="flex flex-wrap gap-1 mt-3">
            {tags.slice(0, 3).map((tag, index) => (
              <Badge key={index} variant="outline" className="text-xs font-normal">
                {tag}
              </Badge>
            ))}
            {tags.length > 3 && (
              <Badge variant="outline" className="text-xs font-normal">
                +{tags.length - 3}
              </Badge>
            )}
          </div>
        )}
      </CardContent>
    </Card>
  );
};

export default OpportunityCard;

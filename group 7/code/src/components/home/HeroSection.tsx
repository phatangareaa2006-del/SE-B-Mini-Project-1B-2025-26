import { Zap } from "lucide-react";

interface HeroSectionProps {
  talentCount?: string;
}

const HeroSection = ({ talentCount = "28Mn+" }: HeroSectionProps) => {
  return (
    <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-8">
      <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold">
        Unlock Your{" "}
        <span className="text-primary bg-clip-text">Career!</span>
      </h1>
      
      <div className="flex items-center gap-2 text-sm text-muted-foreground bg-muted/50 px-4 py-2 rounded-full">
        <Zap className="h-4 w-4 text-yellow-500 fill-yellow-500" />
        <span>
          <strong className="text-foreground">{talentCount}</strong> talent inspired to #BeUnstoppable
        </span>
      </div>
    </div>
  );
};

export default HeroSection;

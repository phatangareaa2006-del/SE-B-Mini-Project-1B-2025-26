import { useState, useEffect, useRef } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import OpportunityCard from "./OpportunityCard";
import { cn } from "@/lib/utils";

interface Opportunity {
  id: string;
  title: string;
  organizer_name?: string;
  organizer_logo?: string;
  image_url?: string;
  mode?: string;
  is_free?: boolean;
  location?: string;
  start_date?: string;
  end_date?: string;
  registration_deadline?: string;
  prize_pool?: number;
  stipend_min?: number;
  stipend_max?: number;
  tags?: string[];
  current_participants?: number;
  opportunity_type: string;
}

interface FeaturedCarouselProps {
  opportunities: Opportunity[];
  title?: string;
  isLoading?: boolean;
}

const FeaturedCarousel = ({ opportunities, title = "Featured", isLoading }: FeaturedCarouselProps) => {
  const scrollRef = useRef<HTMLDivElement>(null);
  const [canScrollLeft, setCanScrollLeft] = useState(false);
  const [canScrollRight, setCanScrollRight] = useState(true);

  const checkScrollButtons = () => {
    if (scrollRef.current) {
      const { scrollLeft, scrollWidth, clientWidth } = scrollRef.current;
      setCanScrollLeft(scrollLeft > 0);
      setCanScrollRight(scrollLeft < scrollWidth - clientWidth - 10);
    }
  };

  useEffect(() => {
    checkScrollButtons();
    const ref = scrollRef.current;
    if (ref) {
      ref.addEventListener("scroll", checkScrollButtons);
      return () => ref.removeEventListener("scroll", checkScrollButtons);
    }
  }, [opportunities]);

  const scroll = (direction: "left" | "right") => {
    if (scrollRef.current) {
      const scrollAmount = direction === "left" ? -350 : 350;
      scrollRef.current.scrollBy({ left: scrollAmount, behavior: "smooth" });
    }
  };

  if (isLoading) {
    return (
      <div className="space-y-4">
        <div className="flex items-center gap-2">
          <div className="w-1 h-6 bg-primary rounded-full" />
          <h2 className="text-2xl font-bold">{title}</h2>
        </div>
        <div className="flex gap-6 overflow-hidden">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="min-w-[300px] h-[380px] bg-muted animate-pulse rounded-xl" />
          ))}
        </div>
      </div>
    );
  }

  if (opportunities.length === 0) {
    return null;
  }

  return (
    <div className="space-y-4 relative">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <div className="w-1 h-6 bg-primary rounded-full" />
          <h2 className="text-2xl font-bold text-foreground">{title}</h2>
        </div>
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="icon"
            onClick={() => scroll("left")}
            disabled={!canScrollLeft}
            className="rounded-full"
          >
            <ChevronLeft className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() => scroll("right")}
            disabled={!canScrollRight}
            className="rounded-full"
          >
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
      </div>

      <div
        ref={scrollRef}
        className="flex gap-6 overflow-x-auto scrollbar-hide pb-4 -mx-2 px-2 snap-x"
        style={{ scrollbarWidth: "none", msOverflowStyle: "none" }}
      >
        {opportunities.map((opportunity) => (
          <div
            key={opportunity.id}
            className="min-w-[300px] max-w-[300px] snap-start"
          >
            <OpportunityCard
              id={opportunity.id}
              title={opportunity.title}
              organizerName={opportunity.organizer_name}
              organizerLogo={opportunity.organizer_logo}
              imageUrl={opportunity.image_url}
              mode={opportunity.mode}
              isFree={opportunity.is_free}
              location={opportunity.location}
              startDate={opportunity.start_date}
              endDate={opportunity.end_date}
              registrationDeadline={opportunity.registration_deadline}
              prizePool={opportunity.prize_pool}
              stipendMin={opportunity.stipend_min}
              stipendMax={opportunity.stipend_max}
              tags={opportunity.tags}
              currentParticipants={opportunity.current_participants}
              opportunityType={opportunity.opportunity_type}
            />
          </div>
        ))}
      </div>
    </div>
  );
};

export default FeaturedCarousel;

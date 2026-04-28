import { Link } from "react-router-dom";
import { cn } from "@/lib/utils";

interface CategoryCardProps {
  title: string;
  icon: React.ReactNode;
  href: string;
  gradient?: string;
  count?: number;
}

const CategoryCard = ({ title, icon, href, gradient, count }: CategoryCardProps) => {
  return (
    <Link
      to={href}
      className={cn(
        "group flex flex-col items-center justify-center gap-3 p-6 rounded-2xl",
        "bg-gradient-to-br from-primary/5 to-primary/10 hover:from-primary/10 hover:to-primary/20",
        "border border-border/50 hover:border-primary/30",
        "transition-all duration-300 hover:scale-105 hover:shadow-lg",
        "min-w-[140px] cursor-pointer"
      )}
    >
      <div className={cn(
        "w-16 h-16 rounded-xl flex items-center justify-center",
        "bg-gradient-to-br",
        gradient || "from-primary/20 to-primary/30",
        "group-hover:scale-110 transition-transform duration-300"
      )}>
        {icon}
      </div>
      <span className="font-medium text-foreground group-hover:text-primary transition-colors">
        {title}
      </span>
      {count !== undefined && (
        <span className="text-xs text-muted-foreground">{count.toLocaleString()}+ opportunities</span>
      )}
    </Link>
  );
};

export default CategoryCard;

import { useState } from "react";
import { Search, X } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

interface SearchBarProps {
  onSearch?: (query: string) => void;
  placeholder?: string;
  className?: string;
}

const SearchBar = ({ 
  onSearch, 
  placeholder = "Search Opportunities",
  className 
}: SearchBarProps) => {
  const [query, setQuery] = useState("");
  const [isFocused, setIsFocused] = useState(false);

  const handleSearch = () => {
    onSearch?.(query);
  };

  const handleClear = () => {
    setQuery("");
    onSearch?.("");
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter") {
      handleSearch();
    }
  };

  return (
    <div 
      className={cn(
        "relative flex items-center w-full max-w-2xl mx-auto",
        "bg-muted/50 rounded-full border border-border/50",
        "transition-all duration-200",
        isFocused && "ring-2 ring-primary/20 border-primary/50",
        className
      )}
    >
      <Search className="h-5 w-5 text-muted-foreground ml-4 shrink-0" />
      <Input
        type="text"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
        onKeyDown={handleKeyDown}
        placeholder={placeholder}
        className="border-0 bg-transparent focus-visible:ring-0 focus-visible:ring-offset-0 px-3 py-6"
      />
      {query && (
        <Button
          variant="ghost"
          size="icon"
          className="mr-1 h-8 w-8 shrink-0"
          onClick={handleClear}
        >
          <X className="h-4 w-4" />
        </Button>
      )}
      <Button 
        onClick={handleSearch}
        className="rounded-full mr-1.5 px-6"
      >
        Search
      </Button>
    </div>
  );
};

export default SearchBar;

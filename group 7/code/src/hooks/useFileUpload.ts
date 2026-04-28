import { useState } from "react";
import { apiClient } from "@/api/client";
import { toast } from "sonner";

interface UploadOptions {
  bucket?: string;
  folder?: string;
  userId?: string;
  acceptedTypes?: string[];
  maxSizeMB?: number;
  type?: 'avatar' | 'resume' | 'certificate' | 'project-image';
}

export const useFileUpload = () => {
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);

  const uploadFile = async (
    file: File,
    options: UploadOptions = {}
  ): Promise<string | null> => {
    const { acceptedTypes, maxSizeMB = 5, type = 'avatar' } = options;

    // Validate file type
    if (acceptedTypes && !acceptedTypes.some((fileType) => file.type.includes(fileType))) {
      toast.error(`Invalid file type. Accepted: ${acceptedTypes.join(", ")}`);
      return null;
    }

    // Validate file size
    if (file.size > maxSizeMB * 1024 * 1024) {
      toast.error(`File too large. Maximum size: ${maxSizeMB}MB`);
      return null;
    }

    setUploading(true);
    setProgress(0);

    try {
      let result: any = null;
      
      // Use the appropriate upload method based on file type
      switch (type) {
        case 'avatar':
          result = await apiClient.uploadAvatar(file, (prog) => setProgress(prog));
          break;
        case 'resume':
          result = await apiClient.uploadResume(file, (prog) => setProgress(prog));
          break;
        case 'certificate':
          result = await apiClient.uploadCertificate(file, (prog) => setProgress(prog));
          break;
        case 'project-image':
          result = await apiClient.uploadProjectImage(file, (prog) => setProgress(prog));
          break;
        default:
          result = await apiClient.uploadAvatar(file, (prog) => setProgress(prog));
      }

      setProgress(100);
      toast.success("File uploaded successfully!");
      
      // Return the URL from the response
      return result.url || result.data?.url || result;
    } catch (error: any) {
      console.error("Upload error:", error);
      toast.error(error.message || "Failed to upload file");
      return null;
    } finally {
      setUploading(false);
    }
  };

  const deleteFile = async (filePath: string): Promise<boolean> => {
    try {
      await apiClient.deleteFile(filePath);
      toast.success("File deleted successfully!");
      return true;
    } catch (error: any) {
      console.error("Delete error:", error);
      toast.error("Failed to delete file");
      return false;
    }
  };

  return { uploadFile, deleteFile, uploading, progress };
};

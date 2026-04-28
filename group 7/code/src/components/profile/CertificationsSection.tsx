import { useState, useRef } from "react";
import { Award, Plus, Pencil, Trash2, X, Check, Loader2, Upload, FileText, ExternalLink } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { useFileUpload } from "@/hooks/useFileUpload";

type Certification = Database["public"]["Tables"]["certifications"]["Row"];

interface CertificationsSectionProps {
  certifications: Certification[];
  userId: string;
  onAdd: (cert: Omit<Certification, "id" | "created_at" | "updated_at" | "user_id">) => Promise<Certification | null>;
  onUpdate: (id: string, updates: Partial<Certification>) => Promise<boolean>;
  onDelete: (id: string) => Promise<boolean>;
}

const emptyForm = {
  name: "",
  issuing_organization: "",
  issue_date: "",
  expiry_date: "",
  credential_id: "",
  credential_url: "",
  certificate_url: "",
};

export const CertificationsSection = ({
  certifications,
  userId,
  onAdd,
  onUpdate,
  onDelete,
}: CertificationsSectionProps) => {
  const [isAdding, setIsAdding] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [formData, setFormData] = useState(emptyForm);
  const [saving, setSaving] = useState(false);
  
  const fileInputRef = useRef<HTMLInputElement>(null);
  const { uploadFile, uploading } = useFileUpload();

  const formatDate = (date: string | null) => {
    if (!date) return "";
    return new Date(date).toLocaleDateString("en-IN", {
      month: "short",
      year: "numeric",
    });
  };

  const openAdd = () => {
    setFormData(emptyForm);
    setIsAdding(true);
  };

  const openEdit = (cert: Certification) => {
    setFormData({
      name: cert.name,
      issuing_organization: cert.issuing_organization,
      issue_date: cert.issue_date || "",
      expiry_date: cert.expiry_date || "",
      credential_id: cert.credential_id || "",
      credential_url: cert.credential_url || "",
      certificate_url: cert.certificate_url || "",
    });
    setEditingId(cert.id);
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const url = await uploadFile(file, {
      bucket: "profile-uploads",
      folder: "certificates",
      userId,
      acceptedTypes: ["application/pdf", "image/"],
      maxSizeMB: 10,
    });

    if (url) {
      setFormData((prev) => ({ ...prev, certificate_url: url }));
    }
  };

  const handleSave = async () => {
    setSaving(true);
    const data = {
      name: formData.name,
      issuing_organization: formData.issuing_organization,
      issue_date: formData.issue_date || null,
      expiry_date: formData.expiry_date || null,
      credential_id: formData.credential_id || null,
      credential_url: formData.credential_url || null,
      certificate_url: formData.certificate_url || null,
    };

    if (editingId) {
      const success = await onUpdate(editingId, data);
      if (success) setEditingId(null);
    } else {
      const result = await onAdd(data);
      if (result) setIsAdding(false);
    }
    setSaving(false);
  };

  const handleDelete = async () => {
    if (!deleteId) return;
    await onDelete(deleteId);
    setDeleteId(null);
  };

  const closeDialog = () => {
    setIsAdding(false);
    setEditingId(null);
    setFormData(emptyForm);
  };

  return (
    <>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle className="flex items-center gap-2">
            <Award className="h-5 w-5" />
            Certifications
          </CardTitle>
          <Button variant="outline" size="sm" className="gap-1" onClick={openAdd}>
            <Plus className="h-4 w-4" />
            Add
          </Button>
        </CardHeader>
        <CardContent>
          {certifications.length === 0 ? (
            <p className="text-muted-foreground italic text-center py-8">
              Add your certifications and achievements
            </p>
          ) : (
            <div className="space-y-4">
              {certifications.map((cert) => (
                <div key={cert.id} className="flex items-center gap-4 group">
                  <div className="h-10 w-10 rounded-lg bg-muted flex items-center justify-center shrink-0">
                    <Award className="h-5 w-5 text-muted-foreground" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h4 className="font-medium truncate">{cert.name}</h4>
                    <p className="text-sm text-muted-foreground truncate">
                      {cert.issuing_organization}
                      {cert.issue_date && ` • ${formatDate(cert.issue_date)}`}
                    </p>
                  </div>
                  <div className="flex gap-1 shrink-0">
                    {cert.certificate_url && (
                      <a href={cert.certificate_url} target="_blank" rel="noopener noreferrer">
                        <Button variant="ghost" size="icon" className="h-8 w-8">
                          <FileText className="h-4 w-4" />
                        </Button>
                      </a>
                    )}
                    {cert.credential_url && (
                      <a href={cert.credential_url} target="_blank" rel="noopener noreferrer">
                        <Button variant="outline" size="sm" className="gap-1">
                          <ExternalLink className="h-3 w-3" />
                          Verify
                        </Button>
                      </a>
                    )}
                    <div className="opacity-0 group-hover:opacity-100 transition-opacity flex">
                      <Button
                        variant="ghost"
                        size="icon"
                        className="h-8 w-8"
                        onClick={() => openEdit(cert)}
                      >
                        <Pencil className="h-3 w-3" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="icon"
                        className="h-8 w-8 text-destructive"
                        onClick={() => setDeleteId(cert.id)}
                      >
                        <Trash2 className="h-3 w-3" />
                      </Button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Add/Edit Dialog */}
      <Dialog open={isAdding || !!editingId} onOpenChange={closeDialog}>
        <DialogContent className="max-w-lg max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              {editingId ? "Edit Certification" : "Add Certification"}
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <div>
              <Label htmlFor="name">Certification Name *</Label>
              <Input
                id="name"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder="AWS Solutions Architect"
              />
            </div>
            <div>
              <Label htmlFor="issuing_organization">Issuing Organization *</Label>
              <Input
                id="issuing_organization"
                value={formData.issuing_organization}
                onChange={(e) =>
                  setFormData({ ...formData, issuing_organization: e.target.value })
                }
                placeholder="Amazon Web Services"
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="issue_date">Issue Date</Label>
                <Input
                  id="issue_date"
                  type="date"
                  value={formData.issue_date}
                  onChange={(e) => setFormData({ ...formData, issue_date: e.target.value })}
                />
              </div>
              <div>
                <Label htmlFor="expiry_date">Expiry Date</Label>
                <Input
                  id="expiry_date"
                  type="date"
                  value={formData.expiry_date}
                  onChange={(e) => setFormData({ ...formData, expiry_date: e.target.value })}
                />
              </div>
            </div>
            <div>
              <Label htmlFor="credential_id">Credential ID</Label>
              <Input
                id="credential_id"
                value={formData.credential_id}
                onChange={(e) => setFormData({ ...formData, credential_id: e.target.value })}
                placeholder="ABC123XYZ"
              />
            </div>
            <div>
              <Label htmlFor="credential_url">Credential URL</Label>
              <Input
                id="credential_url"
                value={formData.credential_url}
                onChange={(e) => setFormData({ ...formData, credential_url: e.target.value })}
                placeholder="https://www.credly.com/badges/..."
              />
            </div>
            <div>
              <Label>Certificate File (PDF/Image)</Label>
              <input
                ref={fileInputRef}
                type="file"
                accept=".pdf,image/*"
                className="hidden"
                onChange={handleFileUpload}
              />
              <div className="mt-2">
                {formData.certificate_url ? (
                  <div className="flex items-center gap-2 p-2 bg-muted rounded-lg">
                    <FileText className="h-4 w-4" />
                    <span className="text-sm truncate flex-1">Certificate uploaded</span>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setFormData({ ...formData, certificate_url: "" })}
                    >
                      <X className="h-4 w-4" />
                    </Button>
                  </div>
                ) : (
                  <Button
                    variant="outline"
                    className="w-full"
                    onClick={() => fileInputRef.current?.click()}
                    disabled={uploading}
                  >
                    {uploading ? (
                      <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    ) : (
                      <Upload className="h-4 w-4 mr-2" />
                    )}
                    Upload Certificate
                  </Button>
                )}
              </div>
            </div>
            <div className="flex gap-2 justify-end pt-4">
              <Button variant="outline" onClick={closeDialog}>
                <X className="h-4 w-4 mr-1" />
                Cancel
              </Button>
              <Button
                onClick={handleSave}
                disabled={saving || !formData.name || !formData.issuing_organization}
              >
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

      {/* Delete Confirmation */}
      <AlertDialog open={!!deleteId} onOpenChange={() => setDeleteId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Certification?</AlertDialogTitle>
            <AlertDialogDescription>
              This action cannot be undone. This will permanently delete this certification.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleDelete} className="bg-destructive text-destructive-foreground">
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
};

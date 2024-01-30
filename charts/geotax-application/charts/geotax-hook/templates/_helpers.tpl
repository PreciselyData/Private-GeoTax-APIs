{{/*
Expand the name of the chart.
*/}}
{{- define "geotax-hook.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Storage Class Name
*/}}
{{- define "geotax-hook-storage-class.name" -}}
{{- printf "%s-%s" "hook-efs" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Persistent Volume Name
*/}}
{{- define "geotax-hook-pv.name" -}}
{{- printf "%s-%s-%s" "hook" .Release.Name "pv" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Persistent Volume Claim Name
*/}}
{{- define "geotax-hook-pvc.name" -}}
{{- printf "%s-%s-%s" "hook" .Release.Name "pvc" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common PV labels
*/}}
{{- define "geotax-hook-pv.labels" -}}
app.kubernetes.io/name: {{ include "geotax-hook-pv.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common PVC labels
*/}}
{{- define "geotax-hook-pvc.labels" -}}
app.kubernetes.io/name: {{ include "geotax-hook-pvc.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "geotax-hook.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "geotax-hook.labels" -}}
helm.sh/chart: {{ include "geotax-hook.chart" . }}
{{ include "geotax-hook.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "geotax-hook.selectorLabels" -}}
app.kubernetes.io/name: {{ include "geotax-hook.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
volumeMounts
*/}}
{{- define "addressing-hook.volumeMounts" -}}
- name: geoaddressing-host-volume
  mountPath: {{ .Values.global.efs.volumeMountPath }}
{{- end }}